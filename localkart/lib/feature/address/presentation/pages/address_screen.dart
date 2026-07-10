import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:localkart/app/theme/app_colors.dart';
import 'package:localkart/core/utils/snackbar_utils.dart';
import 'package:localkart/feature/address/domain/entities/address_entity.dart';
import 'package:localkart/feature/address/presentation/states/address_state.dart';
import 'package:localkart/feature/address/presentation/view_model/address_view_model.dart';

class AddressScreen extends ConsumerStatefulWidget {
  const AddressScreen({super.key});

  @override
  ConsumerState<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends ConsumerState<AddressScreen> {
  /// Track whether we are in the middle of a mutation operation
  /// so the FAB and action buttons can show a loading indicator.
  bool _isMutationInProgress = false;

  /// Track which operation is currently running so we show the right message.
  String _currentOperation = ''; // 'create' | 'update' | 'delete'

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(addressViewModelProvider.notifier).getAddresses();
    });
  }

  /// Listen for error state changes and show a SnackBar
  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    SnackbarUtils.showError(context, message);
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    SnackbarUtils.showSuccess(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addressViewModelProvider);

    // React to state transitions caused by backend mutations.
    // The view model internally calls getAddresses() after create/update/delete
    // success, which triggers a second loading->loaded cycle. We only respond
    // to the FIRST loading->loaded transition to avoid duplicate messages.
    ref.listen<AddressState>(addressViewModelProvider, (previous, next) {
      if (!mounted) return;

      if (previous?.status == AddressStatus.loading &&
          next.status == AddressStatus.error) {
        if (_isMutationInProgress) {
          _isMutationInProgress = false;
          _currentOperation = '';
          _showErrorSnackBar(next.errorMessage ?? "Operation failed");
        }
      }
      if (previous?.status == AddressStatus.loading &&
          next.status == AddressStatus.loaded) {
        if (_isMutationInProgress) {
          _isMutationInProgress = false;
          final op = _currentOperation;
          _currentOperation = '';
          switch (op) {
            case 'create':
              _showSuccessSnackBar("Address added successfully");
            case 'update':
              _showSuccessSnackBar("Address updated successfully");
            case 'delete':
              _showSuccessSnackBar("Address deleted successfully");
            default:
              _showSuccessSnackBar("Address saved successfully");
          }
        }
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "My Addresses",
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButton: _isMutationInProgress
          ? null
          : FloatingActionButton(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              onPressed: () => _showAddAddressSheet(context),
              child: const Icon(Icons.add, size: 30),
            ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(AddressState state) {
    switch (state.status) {
      case AddressStatus.initial:
      case AddressStatus.loading:
        // During initial load (not a mutation), show centered spinner
        if (!_isMutationInProgress && state.addresses == null) {
          return const Center(child: CircularProgressIndicator());
        }
        // If we already have data, show it (mutation in background)
        if (state.addresses != null) {
          return _buildAddressList(state.addresses!);
        }
        return const Center(child: CircularProgressIndicator());

      case AddressStatus.error:
        // If we have cached addresses, still show them with a retry banner
        if (state.addresses != null && state.addresses!.isNotEmpty) {
          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: AppColors.error.withValues(alpha: 0.1),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        size: 18, color: AppColors.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        state.errorMessage ?? "Something went wrong",
                        style: const TextStyle(
                            color: AppColors.error, fontSize: 13),
                      ),
                    ),
                    TextButton(
                      onPressed: () => ref
                          .read(addressViewModelProvider.notifier)
                          .getAddresses(),
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              ),
              Expanded(child: _buildAddressList(state.addresses!)),
            ],
          );
        }
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off_rounded,
                  size: 56, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                state.errorMessage ?? "Could not load addresses",
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () =>
                    ref.read(addressViewModelProvider.notifier).getAddresses(),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text("Retry"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        );

      case AddressStatus.loaded:
        final addresses = state.addresses ?? [];
        if (addresses.isEmpty) {
          return _buildEmptyState();
        }
        return _buildAddressList(addresses);
    }
  }

  Widget _buildAddressList(List<AddressEntity> addresses) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        await ref.read(addressViewModelProvider.notifier).getAddresses();
      },
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        itemCount: addresses.length,
        itemBuilder: (context, index) =>
            _buildAddressCard(addresses[index]),
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        await ref.read(addressViewModelProvider.notifier).getAddresses();
      },
      child: ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off_rounded,
                      size: 80,
                      color: AppColors.textSecondary.withValues(alpha: 0.4)),
                  const SizedBox(height: 16),
                  const Text(
                    "No addresses yet",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Add an address to get started",
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showAddAddressSheet(context),
                    icon: const Icon(Icons.add),
                    label: const Text("Add Address"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(AddressEntity address) {
    final icon = _getLabelIcon(address.label);
    final color = _getLabelColor(address.label);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            address.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (address.addressId != null)
                          Text(
                            "#${address.addressId!.length >= 6 ? address.addressId!.substring(address.addressId!.length - 4).toUpperCase() : address.addressId!}",
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      address.fullAddress,
                      style: const TextStyle(
                        height: 1.6,
                        color: AppColors.textSecondary,
                        fontSize: 15,
                      ),
                    ),
                    if (address.createdAt != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          "Added ${_formatDate(address.createdAt!)}",
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 28),
          Row(
            children: [
              InkWell(
                onTap: _isMutationInProgress
                    ? null
                    : () => _showEditAddressSheet(context, address),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined,
                          size: 18,
                          color: _isMutationInProgress
                              ? AppColors.grey
                              : AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        "Edit",
                        style: TextStyle(
                          color: _isMutationInProgress
                              ? AppColors.grey
                              : AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              InkWell(
                onTap: _isMutationInProgress
                    ? null
                    : () => _confirmDelete(context, address),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline,
                          size: 18,
                          color: _isMutationInProgress
                              ? AppColors.grey
                              : AppColors.error),
                      const SizedBox(width: 6),
                      Text(
                        "Delete",
                        style: TextStyle(
                          color: _isMutationInProgress
                              ? AppColors.grey
                              : AppColors.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getLabelIcon(String label) {
    switch (label.toLowerCase()) {
      case 'home':
        return Icons.home_rounded;
      case 'work':
        return Icons.work_rounded;
      default:
        return Icons.location_on_rounded;
    }
  }

  Color _getLabelColor(String label) {
    switch (label.toLowerCase()) {
      case 'home':
        return AppColors.primary;
      case 'work':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      const months = [
        "Jan", "Feb", "Mar", "Apr", "May", "Jun",
        "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
      ];
      return "${date.day} ${months[date.month - 1]}, ${date.year}";
    } catch (_) {
      return dateStr;
    }
  }

  void _showAddAddressSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),              builder: (_) => _AddressFormSheet(
        isEditing: false,
        onSubmitting: () => _onMutationStart('create'),
      ),
    );
  }

  void _showEditAddressSheet(BuildContext context, AddressEntity address) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),              builder: (_) => _AddressFormSheet(
        isEditing: true,
        address: address,
        onSubmitting: () => _onMutationStart('update'),
      ),
    );
  }

  void _confirmDelete(BuildContext context, AddressEntity address) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline, color: AppColors.error, size: 24),
            SizedBox(width: 10),
            Text("Delete Address",
                style: TextStyle(color: AppColors.textPrimary, fontSize: 18)),
          ],
        ),
        content: Text(
          "Are you sure you want to delete your ${address.label.toLowerCase()} address?\n\n\"${address.fullAddress.length > 50 ? '${address.fullAddress.substring(0, 50)}...' : address.fullAddress}\"",
          style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel",
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _onMutationStart('delete');
              ref
                  .read(addressViewModelProvider.notifier)
                  .deleteAddress(address.addressId ?? '');
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text("Delete",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _onMutationStart(String operation) {
    setState(() {
      _isMutationInProgress = true;
      _currentOperation = operation;
    });
  }
}

// =========================================================================
// Bottom Sheet Form
// =========================================================================

class _AddressFormSheet extends ConsumerStatefulWidget {
  final bool isEditing;
  final AddressEntity? address;
  final VoidCallback onSubmitting;

  const _AddressFormSheet({
    required this.isEditing,
    this.address,
    required this.onSubmitting,
  });

  @override
  ConsumerState<_AddressFormSheet> createState() => _AddressFormSheetState();
}

class _AddressFormSheetState extends ConsumerState<_AddressFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _addressController;
  late final TextEditingController _searchController;
  late final FocusNode _addressFocusNode;
  final MapController _mapController = MapController();
  final Geocoding _geocoding = Geocoding();
  String _selectedLabel = 'Home';
  bool _isSubmitting = false;

  // Location & map state
  bool _isLoadingLocation = true;
  bool _isReversingGeocoding = false;
  LatLng _selectedLocation = const LatLng(27.7172, 85.3240); // fallback: Kathmandu
  LatLng? _currentLocation;

  // Search state (forward geocoding)
  bool _isSearching = false;
  List<Location> _searchResults = [];

  // Track whether the user has manually edited the address field.
  // When false, map movements will auto-fill the address from reverse geocoding.
  // When true (user has typed/focused + changed the field), we stop overwriting.
  bool _addressManuallyEdited = false;

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController(
      text: widget.isEditing ? widget.address?.fullAddress : '',
    );
    _searchController = TextEditingController();
    _addressFocusNode = FocusNode();

    // Detect manual edits: if the user focuses the field and types/edits,
    // mark it so we don't overwrite their changes on further map movements.
    _addressController.addListener(() {
      if (_addressFocusNode.hasFocus && _addressController.text.isNotEmpty) {
        _addressManuallyEdited = true;
      }
    });

    if (widget.isEditing && widget.address != null) {
      _selectedLabel = widget.address!.label;
      _selectedLocation = LatLng(
        widget.address!.latitude,
        widget.address!.longitude,
      );
      _isLoadingLocation = false;
    } else {
      _getCurrentLocation();
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _searchController.dispose();
    _addressFocusNode.dispose();
    _mapController.dispose();
    super.dispose();
  }

  // ── Forward geocoding: search for a place ──

  Future<void> _searchLocation(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    try {
      final locations = await _geocoding.locationFromAddress(query);
      if (!mounted) return;

      setState(() {
        _searchResults = locations;
        _isSearching = false;
      });

      if (locations.isNotEmpty) {
        final loc = locations.first;
        final newLoc = LatLng(loc.latitude, loc.longitude);
        setState(() {
          _selectedLocation = newLoc;
          // Fill the address text with the search query
          _addressController.text = query;
          _addressManuallyEdited = true; // don't overwrite on map pan
        });
        _mapController.move(newLoc, 15);
      }
    } catch (_) {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _selectSearchResult(int index) {
    if (index >= _searchResults.length) return;
    final loc = _searchResults[index];
    final newLoc = LatLng(loc.latitude, loc.longitude);
    setState(() {
      _selectedLocation = newLoc;
      _addressController.text = _searchController.text.trim();
      _addressManuallyEdited = true;
      _searchResults = [];
    });
    _mapController.move(newLoc, 15);
  }

  // ── Current location detection ──

  Future<void> _getCurrentLocation() async {
    try {
      // 1. Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() => _isLoadingLocation = false);
          _showSnackBar(
            'Location services are disabled. Please enable them in your device settings.',
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () => Geolocator.openLocationSettings(),
            ),
          );
        }
        return;
      }

      // 2. Check and request location permission
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            setState(() => _isLoadingLocation = false);
            _showSnackBar(
              'Location permission is required to detect your current address.',
            );
          }
          return;
        }
      }

      // 3. Handle permanently denied permission
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() => _isLoadingLocation = false);
          _showPermissionDeniedDialog();
        }
        return;
      }

      // 4. Get the current position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      final latLng = LatLng(position.latitude, position.longitude);
      if (!mounted) return;

      setState(() {
        _currentLocation = latLng;
        _selectedLocation = latLng;
        _isLoadingLocation = false;
        // Re-enable auto-fill when the user explicitly requests current location
        _addressManuallyEdited = false;
        // Clear search state
        _searchController.clear();
        _searchResults = [];
        _isSearching = false;
      });

      // Move map to current location (after first frame)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _mapController.move(latLng, 16);
        }
      });

      // Reverse geocode to get the address name
      _reverseGeocode(latLng);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
        String msg = 'Could not detect your location. Please try again or type your address manually.';
        if (e.toString().contains('timeout') || e.toString().contains('Timeout')) {
          msg = 'Location request timed out. Make sure GPS is enabled and try again.';
        }
        _showSnackBar(msg);
      }
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.location_off, color: AppColors.error, size: 24),
            SizedBox(width: 10),
            Text('Location Permission',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 18)),
          ],
        ),
        content: const Text(
          'Location permission has been permanently denied. Please enable it from your device settings to automatically detect your address.',
          style: TextStyle(color: AppColors.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Geolocator.openAppSettings();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            child: const Text('Open Settings',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {SnackBarAction? action}) {
    if (!mounted) return;
    SnackbarUtils.showError(
      context,
      message,
      duration: const Duration(seconds: 5),
      action: action,
    );
  }

  // ── Reverse geocoding: convert coordinates to address ──

  Future<void> _reverseGeocode(LatLng position) async {
    if (_isReversingGeocoding) return;
    setState(() => _isReversingGeocoding = true);
    try {
      final placemarks = await _geocoding.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (!mounted) return;

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final parts = <String>[
          if (place.street != null && place.street!.isNotEmpty) place.street!,
          if (place.subLocality != null && place.subLocality!.isNotEmpty)
            place.subLocality!,
          if (place.locality != null && place.locality!.isNotEmpty)
            place.locality!,
          if (place.administrativeArea != null &&
              place.administrativeArea!.isNotEmpty)
            place.administrativeArea!,
          if (place.country != null && place.country!.isNotEmpty)
            place.country!,
        ];

        if (parts.isNotEmpty) {
          final address = parts.join(', ');
          // Auto-fill if the user hasn't manually edited the address field
          if (!_addressManuallyEdited) {
            _addressController.text = address;
          }
        }
      }
    } catch (_) {
      // Silent fail — user can type the address manually
    } finally {
      if (mounted) setState(() => _isReversingGeocoding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                widget.isEditing ? "Edit Address" : "Add New Address",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // ── Search bar (forward geocoding) ──
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search for a place...",
                  hintStyle: const TextStyle(color: AppColors.textSecondary),
                  prefixIcon:
                      const Icon(Icons.search, color: AppColors.textSecondary),
                  suffixIcon: _isSearching
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : (_searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear,
                                  color: AppColors.textSecondary),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchResults = []);
                              },
                            )
                          : null),
                  filled: true,
                  fillColor: AppColors.inputFill,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 14, horizontal: 16),
                ),
                onChanged: _searchLocation,
                textInputAction: TextInputAction.search,
              ),
              const SizedBox(height: 10),

              // ── Search results ──
              if (_searchResults.isNotEmpty)
                Container(
                  constraints: const BoxConstraints(maxHeight: 160),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _searchResults.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: AppColors.divider),
                    itemBuilder: (context, index) {
                      final loc = _searchResults[index];
                      final isSelected = _selectedLocation.latitude ==
                              loc.latitude &&
                          _selectedLocation.longitude == loc.longitude;
                      return InkWell(
                        onTap: () => _selectSearchResult(index),
                        borderRadius: index == 0
                            ? const BorderRadius.vertical(
                                top: Radius.circular(12))
                            : index == _searchResults.length - 1
                                ? const BorderRadius.vertical(
                                    bottom: Radius.circular(12))
                                : BorderRadius.zero,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 18,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _searchController.text,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textPrimary,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                              Text(
                                "${loc.latitude.toStringAsFixed(4)}, ${loc.longitude.toStringAsFixed(4)}",
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              if (_searchResults.isNotEmpty) const SizedBox(height: 10),

              // ── Use My Current Location button ──
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isLoadingLocation || _isReversingGeocoding
                      ? null
                      : () {
                          setState(() {
                            _isLoadingLocation = true;
                            _addressManuallyEdited = false;
                            _searchController.clear();
                            _searchResults = [];
                          });
                          _getCurrentLocation();
                        },
                  icon: _isLoadingLocation
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location, color: AppColors.primary),
                  label: Text(
                    _isLoadingLocation
                        ? "Detecting..."
                        : "Use My Current Location",
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Map Picker ──
              _buildMapSection(),
              const SizedBox(height: 20),

              // Label Selection
              const Text(
                "Address Label",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: ['Home', 'Work', 'Other'].map((label) {
                  final selected = _selectedLabel == label;
                  final color = _getColor(label);
                  return Expanded(
                    child: Padding(
                      padding:
                          EdgeInsets.only(right: label == 'Other' ? 0 : 8),
                      child: GestureDetector(
                        onTap: _isSubmitting
                            ? null
                            : () => setState(() => _selectedLabel = label),
                        child: Container(
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: selected
                                ? color.withValues(alpha: 0.15)
                                : AppColors.inputFill,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected ? color : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _getIcon(label),
                                size: 18,
                                color: selected
                                    ? color
                                    : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                label,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: selected
                                      ? color
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Full Address
              const Text(
                "Full Address",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _addressController,
                focusNode: _addressFocusNode,
                maxLines: 3,
                enabled: !_isSubmitting,
                decoration: InputDecoration(
                  hintText: "House number, street, area, city...",
                  filled: true,
                  fillColor: AppColors.inputFill,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(14),
                  suffixIcon: _isReversingGeocoding
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.my_location,
                              color: AppColors.primary),
                          onPressed: _isSubmitting || _isLoadingLocation
                              ? null
                              : () {
                                  setState(() {
                                    _isLoadingLocation = true;
                                    _addressManuallyEdited = false;
                                    _searchController.clear();
                                    _searchResults = [];
                                  });
                                  _getCurrentLocation();
                                },
                          tooltip: "Use current location",
                        ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your address';
                  }
                  if (value.trim().length < 5) {
                    return 'Address must be at least 5 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Coordinates display (subtle)
              Center(
                child: Text(
                  "${_selectedLocation.latitude.toStringAsFixed(5)}, ${_selectedLocation.longitude.toStringAsFixed(5)}",
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    disabledBackgroundColor:
                        AppColors.primary.withValues(alpha: 0.6),
                    disabledForegroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.white),
                          ),
                        )
                      : Text(
                          widget.isEditing
                              ? "Update Address"
                              : "Save Address",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapSection() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: 180,
        child: Stack(
          children: [
            // Map
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _selectedLocation,
                initialZoom: 15,
                onMapEvent: (MapEvent event) {
                  if (event is MapEventMoveEnd) {
                    final center = _mapController.camera.center;
                    _selectedLocation = center;
                    _reverseGeocode(center);
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.localkart.app',
                ),
              ],
            ),

            // Loading overlay
            if (_isLoadingLocation || _isReversingGeocoding)
              Container(
                color: Colors.black26,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.white,
                  ),
                ),
              )
            else
              // Center map pin — stays fixed while the map pans
              IgnorePointer(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Pin shadow
                      Container(
                        width: 12,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 2),
                      // Pin icon
                      const Icon(
                        Icons.location_on,
                        size: 42,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),

            // Top gradient hint
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.touch_app,
                        size: 14, color: AppColors.white),
                    const SizedBox(width: 4),
                    const Text(
                      "Move the map to pin your location",
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Re-centre button
            Positioned(
              right: 8,
              bottom: 8,
              child: Material(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8),
                elevation: 2,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: _currentLocation != null
                      ? () {
                          _mapController.move(_currentLocation!, 16);
                          _selectedLocation = _currentLocation!;
                          _addressManuallyEdited = false;
                          _reverseGeocode(_currentLocation!);
                        }
                      : null,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.gps_fixed,
                      size: 20,
                      color: _currentLocation != null
                          ? AppColors.primary
                          : AppColors.grey,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(String label) {
    switch (label) {
      case 'Home':
        return Icons.home_rounded;
      case 'Work':
        return Icons.work_rounded;
      default:
        return Icons.location_on_rounded;
    }
  }

  Color _getColor(String label) {
    switch (label) {
      case 'Home':
        return AppColors.primary;
      case 'Work':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    widget.onSubmitting();

    final addressText = _addressController.text.trim();

    if (widget.isEditing && widget.address != null) {
      ref.read(addressViewModelProvider.notifier).updateAddress(
            addressId: widget.address!.addressId ?? '',
            label: _selectedLabel,
            fullAddress: addressText,
            latitude: _selectedLocation.latitude,
            longitude: _selectedLocation.longitude,
          );
    } else {
      ref.read(addressViewModelProvider.notifier).createAddress(
            label: _selectedLabel,
            fullAddress: addressText,
            latitude: _selectedLocation.latitude,
            longitude: _selectedLocation.longitude,
          );
    }

    // Close the modal immediately so the user sees the loading state on the main screen
    Navigator.pop(context);
  }
}
