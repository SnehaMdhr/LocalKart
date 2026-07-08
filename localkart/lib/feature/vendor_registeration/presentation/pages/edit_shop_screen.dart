import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:localkart/app/theme/app_colors.dart';
import 'package:localkart/core/utils/snackbar_utils.dart';
import 'package:localkart/core/widgets/custom_button.dart';
import 'package:localkart/core/widgets/custom_text_field.dart';
import 'package:localkart/feature/vendor_registeration/presentation/states/shop_state.dart';
import 'package:localkart/feature/vendor_registeration/presentation/view_model/shop_view_model.dart';

class EditShopScreen extends ConsumerStatefulWidget {
  const EditShopScreen({super.key});

  @override
  ConsumerState<EditShopScreen> createState() => _EditShopScreenState();
}

class _EditShopScreenState extends ConsumerState<EditShopScreen> {
  final _formKey = GlobalKey<FormState>();

  final shopNameController = TextEditingController();
  final addressController = TextEditingController();
  final descriptionController = TextEditingController();

  final Set<String> selectedCategories = {};

  final List<String> allCategories = [
    "Fruits & Vegetables",
    "Dairy & Eggs",
    "Meat & Seafood",
    "Bakery",
    "Beverages",
    "Snacks & Confectionery",
    "Frozen Foods",
    "Organic & Health Foods",
    "Pantry Staples",
    "Baby & Pet",
  ];

  // Map & location state
  final MapController _mapController = MapController();
  final Geocoding _geocoding = Geocoding();
  final TextEditingController _searchController = TextEditingController();
  late final FocusNode _addressFocusNode;

  LatLng _selectedLocation = const LatLng(27.7172, 85.3240);
  LatLng? _currentLocation;
  bool _isLoadingLocation = false;
  bool _isReversingGeocoding = false;
  bool _isSearching = false;
  List<Location> _searchResults = [];
  bool _addressManuallyEdited = false;
  bool _fieldsPopulated = false;

  @override
  void initState() {
    super.initState();
    _addressFocusNode = FocusNode();
    addressController.addListener(() {
      if (_addressFocusNode.hasFocus && addressController.text.isNotEmpty) {
        _addressManuallyEdited = true;
      }
    });
  }

  void _populateFields() {
    if (_fieldsPopulated) return;
    final shop = ref.read(shopViewModelProvider).shopEntity;
    if (shop != null) {
      shopNameController.text = shop.shopName;
      addressController.text = shop.address;
      descriptionController.text = shop.description;
      selectedCategories.addAll(shop.categories);

      // Pre-fill map if shop has coordinates
      if (shop.latitude != null && shop.longitude != null) {
        _selectedLocation = LatLng(shop.latitude!, shop.longitude!);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _mapController.move(_selectedLocation, 15);
          }
        });
      }

      _fieldsPopulated = true;
      setState(() {});
    }
  }

  Future<void> _handleUpdate() async {
    if (_formKey.currentState!.validate()) {
      if (selectedCategories.isEmpty) {
        SnackbarUtils.showError(
          context,
          "Please select at least one category",
        );
        return;
      }
      await ref.read(shopViewModelProvider.notifier).updateShop(
            shopName: shopNameController.text.trim(),
            address: addressController.text.trim(),
            description: descriptionController.text.trim(),
            categories: selectedCategories.toList(),
            latitude: _selectedLocation.latitude,
            longitude: _selectedLocation.longitude,
          );
    }
  }

  @override
  void dispose() {
    shopNameController.dispose();
    addressController.dispose();
    descriptionController.dispose();
    _searchController.dispose();
    _addressFocusNode.dispose();
    _mapController.dispose();
    super.dispose();
  }

  // ── Forward geocoding ──
  Future<void> _searchLocation(String query) async {
    if (query.trim().isEmpty) {
      setState(() { _searchResults = []; _isSearching = false; });
      return;
    }
    setState(() => _isSearching = true);
    try {
      final locations = await _geocoding.locationFromAddress(query);
      if (!mounted) return;
      setState(() { _searchResults = locations; _isSearching = false; });
      if (locations.isNotEmpty) {
        final loc = locations.first;
        final newLoc = LatLng(loc.latitude, loc.longitude);
        setState(() { _selectedLocation = newLoc; addressController.text = query; _addressManuallyEdited = true; });
        _mapController.move(newLoc, 15);
      }
    } catch (_) { if (mounted) setState(() => _isSearching = false); }
  }

  void _selectSearchResult(int index) {
    if (index >= _searchResults.length) return;
    final loc = _searchResults[index];
    final newLoc = LatLng(loc.latitude, loc.longitude);
    setState(() { _selectedLocation = newLoc; addressController.text = _searchController.text.trim(); _addressManuallyEdited = true; _searchResults = []; });
    _mapController.move(newLoc, 15);
  }

  // ── Current location detection ──
  Future<void> _getCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) { setState(() => _isLoadingLocation = false); SnackbarUtils.showError(context, 'Location services are disabled.'); }
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        if (mounted) { setState(() => _isLoadingLocation = false); SnackbarUtils.showError(context, 'Location permission is required.'); }
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 10)),
      );
      final latLng = LatLng(position.latitude, position.longitude);
      if (!mounted) return;
      setState(() { _currentLocation = latLng; _selectedLocation = latLng; _isLoadingLocation = false; _addressManuallyEdited = false; _searchController.clear(); _searchResults = []; });
      WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) _mapController.move(latLng, 16); });
      _reverseGeocode(latLng);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
        SnackbarUtils.showError(context, 'Could not detect your location.');
      }
    }
  }

  // ── Reverse geocoding ──
  Future<void> _reverseGeocode(LatLng position) async {
    if (_isReversingGeocoding) return;
    setState(() => _isReversingGeocoding = true);
    try {
      final placemarks = await _geocoding.placemarkFromCoordinates(position.latitude, position.longitude);
      if (!mounted) return;
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final parts = <String>[
          if (place.street != null && place.street!.isNotEmpty) place.street!,
          if (place.subLocality != null && place.subLocality!.isNotEmpty) place.subLocality!,
          if (place.locality != null && place.locality!.isNotEmpty) place.locality!,
          if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) place.administrativeArea!,
          if (place.country != null && place.country!.isNotEmpty) place.country!,
        ];
        if (parts.isNotEmpty && !_addressManuallyEdited) addressController.text = parts.join(', ');
      }
    } catch (_) {}
    if (mounted) setState(() => _isReversingGeocoding = false);
  }

  @override
  Widget build(BuildContext context) {
    final shopState = ref.watch(shopViewModelProvider);
    final isLoading = shopState.status == ShopStatus.loading;

    // Re-populate if shop data arrives after initial build
    if (!_fieldsPopulated && shopState.shopEntity != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _populateFields());
    }

    ref.listen<ShopState>(shopViewModelProvider, (previous, next) {
      if (next.status == ShopStatus.error) {
        SnackbarUtils.showError(context, next.errorMessage ?? "Failed to update shop", duration: const Duration(seconds: 1));
      } else if (next.status == ShopStatus.loaded && previous?.status == ShopStatus.loading) {
        SnackbarUtils.showSuccess(context, "Shop updated successfully", duration: const Duration(seconds: 1));
        Navigator.pop(context);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text(
          "Edit Shop",
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          "Update Your Shop",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Center(
                        child: Text(
                          "Modify your shop details below",
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                        ),
                      ),
                      const SizedBox(height: 30),

                      /// Store Name
                      const Align(alignment: Alignment.centerLeft, child: Text("Store Name", style: TextStyle(fontWeight: FontWeight.w600))),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: shopNameController,
                        hint: "e.g. Fresh Garden Organics",
                        prefixIcon: Icons.storefront_outlined,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return "Store name is required";
                          if (value.trim().length < 3) return "Store name must be at least 3 characters";
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      /// Categories
                      const Align(alignment: Alignment.centerLeft, child: Text("Business Categories", style: TextStyle(fontWeight: FontWeight.w600))),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: AppColors.inputFill, borderRadius: BorderRadius.circular(18)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 8, runSpacing: 8,
                              children: allCategories.map((category) {
                                final isSelected = selectedCategories.contains(category);
                                return FilterChip(
                                  label: Text(category, style: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal, fontSize: 13)),
                                  selected: isSelected,
                                  onSelected: (selected) { setState(() { if (selected) selectedCategories.add(category); else selectedCategories.remove(category); }); },
                                  selectedColor: AppColors.primary,
                                  checkmarkColor: Colors.white,
                                  backgroundColor: Colors.transparent,
                                  side: BorderSide(color: isSelected ? AppColors.primary : AppColors.textSecondary.withValues(alpha: 0.3)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                );
                              }).toList(),
                            ),
                            if (selectedCategories.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text("${selectedCategories.length} selected", style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      /// ── Location section (search + map) ──
                      const Align(alignment: Alignment.centerLeft, child: Text("Shop Location", style: TextStyle(fontWeight: FontWeight.w600))),
                      const SizedBox(height: 8),

                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: "Search for a place...",
                          hintStyle: const TextStyle(color: AppColors.textSecondary),
                          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                          suffixIcon: _isSearching
                              ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)))
                              : (_searchController.text.isNotEmpty ? IconButton(icon: const Icon(Icons.clear, color: AppColors.textSecondary), onPressed: () { _searchController.clear(); setState(() => _searchResults = []); }) : null),
                          filled: true, fillColor: AppColors.inputFill,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        ),
                        onChanged: _searchLocation,
                        textInputAction: TextInputAction.search,
                      ),
                      const SizedBox(height: 10),

                      if (_searchResults.isNotEmpty)
                        Container(
                          constraints: const BoxConstraints(maxHeight: 140),
                          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.divider)),
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: _searchResults.length,
                            separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.divider),
                            itemBuilder: (context, index) {
                              final loc = _searchResults[index];
                              return InkWell(
                                onTap: () => _selectSearchResult(index),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.location_on_outlined, size: 18, color: AppColors.textSecondary),
                                      const SizedBox(width: 10),
                                      Expanded(child: Text(_searchController.text, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary))),
                                      Text("${loc.latitude.toStringAsFixed(4)}, ${loc.longitude.toStringAsFixed(4)}", style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      if (_searchResults.isNotEmpty) const SizedBox(height: 10),

                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _isLoadingLocation || _isReversingGeocoding ? null : () { setState(() { _isLoadingLocation = true; _addressManuallyEdited = false; _searchController.clear(); _searchResults = []; }); _getCurrentLocation(); },
                          icon: _isLoadingLocation
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.my_location, color: AppColors.primary),
                          label: Text(_isLoadingLocation ? "Detecting..." : "Use My Current Location", style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                          style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.primary), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14)),
                        ),
                      ),
                      const SizedBox(height: 14),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: SizedBox(
                          height: 170,
                          child: Stack(
                            children: [
                              FlutterMap(
                                mapController: _mapController,
                                options: MapOptions(
                                  initialCenter: _selectedLocation,
                                  initialZoom: 15,
                                  onMapEvent: (MapEvent event) {
                                    if (event is MapEventMoveEnd) { _selectedLocation = _mapController.camera.center; _reverseGeocode(_selectedLocation); }
                                  },
                                ),
                                children: [
                                  TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.localkart.app'),
                                ],
                              ),
                              if (_isLoadingLocation || _isReversingGeocoding)
                                Container(color: Colors.black26, child: const Center(child: CircularProgressIndicator(color: AppColors.white)))
                              else
                                IgnorePointer(
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(width: 12, height: 4, decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(2))),
                                        const SizedBox(height: 2),
                                        const Icon(Icons.location_on, size: 40, color: AppColors.primary),
                                      ],
                                    ),
                                  ),
                                ),
                              Positioned(
                                right: 8, bottom: 8,
                                child: Material(
                                  color: AppColors.white, borderRadius: BorderRadius.circular(8), elevation: 2,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: _currentLocation != null
                                        ? () { _mapController.move(_currentLocation!, 16); _selectedLocation = _currentLocation!; _addressManuallyEdited = false; _reverseGeocode(_currentLocation!); }
                                        : null,
                                    child: Container(padding: const EdgeInsets.all(8), child: Icon(Icons.gps_fixed, size: 20, color: _currentLocation != null ? AppColors.primary : AppColors.grey)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Center(
                        child: Text(
                          "${_selectedLocation.latitude.toStringAsFixed(5)}, ${_selectedLocation.longitude.toStringAsFixed(5)}",
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ),
                      const SizedBox(height: 14),

                      /// Address
                      const Align(alignment: Alignment.centerLeft, child: Text("Full Address", style: TextStyle(fontWeight: FontWeight.w600))),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: addressController,
                        focusNode: _addressFocusNode,
                        maxLines: 2,
                        decoration: InputDecoration(
                          filled: true, fillColor: AppColors.inputFill,
                          hintText: "Enter your complete shop address",
                          prefixIcon: const Icon(Icons.location_on_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return "Address is required";
                          if (value.trim().length < 3) return "Address must be at least 3 characters";
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      /// Description
                      const Align(alignment: Alignment.centerLeft, child: Text("Description", style: TextStyle(fontWeight: FontWeight.w600))),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: descriptionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          filled: true, fillColor: AppColors.inputFill,
                          hintText: "Description",
                          prefixIcon: const Padding(padding: EdgeInsets.only(bottom: 45), child: Icon(Icons.description_outlined)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return "Description is required";
                          if (value.trim().length < 10) return "Description must be at least 10 characters";
                          return null;
                        },
                      ),
                      const SizedBox(height: 40),

                      /// Update Button
                      CustomButton(text: "Update Shop", isLoading: isLoading, onPressed: _handleUpdate, borderRadius: 18),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
