import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:localkart/app/theme/app_colors.dart';
import 'package:localkart/core/api/api_endpoints.dart';
import 'package:localkart/core/utils/snackbar_utils.dart';
import 'package:localkart/core/widgets/custom_button.dart';
import 'package:localkart/feature/address/domain/entities/address_entity.dart';
import 'package:localkart/feature/address/presentation/view_model/address_view_model.dart';
import 'package:localkart/feature/cart/domain/entities/cart_entity.dart';
import 'package:localkart/feature/order/presentation/pages/order_status_screen.dart';
import 'package:localkart/feature/cart/presentation/view_model/cart_view_model.dart';
import 'package:localkart/feature/order/presentation/view_model/order_view_model.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _addressController = TextEditingController();
  String _selectedPayment = "Cash on Delivery";
  bool _isPlacingOrder = false;

  // Address selection state
  AddressEntity? _selectedAddress;
  LatLng _selectedLocation = const LatLng(27.7172, 85.3240); // fallback

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(addressViewModelProvider.notifier).getAddresses();
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  int _calculateSubtotal(CartEntity cart) {
    return cart.items.fold<int>(
      0,
      (sum, item) => sum + ((item.price ?? 0) * item.quantity),
    );
  }

  Future<void> _placeOrder(CartEntity cart) async {
    final address = _addressController.text.trim();
    if (address.isEmpty) {
      SnackbarUtils.showError(context, "Please enter your delivery address");
      return;
    }

    setState(() => _isPlacingOrder = true);

    final order = await ref.read(orderViewModelProvider.notifier).placeOrder(
      deliveryAddress: address,
      latitude: _selectedLocation.latitude,
      longitude: _selectedLocation.longitude,
      paymentMethod: _selectedPayment,
    );

    if (!mounted) return;
    setState(() => _isPlacingOrder = false);

    if (order != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OrderStatusScreen(order: order),
        ),
      );
      ref.read(cartViewModelProvider.notifier).getCart();
    } else {
      final orderState = ref.read(orderViewModelProvider);
      final errorMsg = orderState.errorMessage ?? "Failed to place order. Please try again.";

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.error_outline, color: AppColors.error, size: 24),
              SizedBox(width: 10),
              Text(
                "Order Failed",
                style: TextStyle(color: AppColors.textPrimary, fontSize: 18),
              ),
            ],
          ),
          content: Text(
            errorMsg,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                "Try Again",
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    }
  }


  void _showAddressPickerSheet() {
    final addressState = ref.read(addressViewModelProvider);
    final savedAddresses = addressState.addresses ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _AddressPickerSheet(
        savedAddresses: savedAddresses,
        selectedAddress: _selectedAddress,
        selectedLocation: _selectedLocation,
        onAddressPicked: (address, location) {
          setState(() {
            _addressController.text = address;
            _selectedLocation = location;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartViewModelProvider);
    final cart = cartState.cart;
    final items = cart?.items ?? [];
    final subtotal = cart != null ? _calculateSubtotal(cart) : 0;

  

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Checkout",
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: items.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 72, color: AppColors.grey),
                  SizedBox(height: 16),
                  Text(
                    "Your cart is empty",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 100),
              children: [
                const SizedBox(height: 16),
                _sectionHeader("Delivery Address"),
                const SizedBox(height: 12),
                _buildAddressField(),
                const SizedBox(height: 24),
                _sectionHeader("Payment Method"),
                const SizedBox(height: 12),
                _buildPaymentSelector(),
                const SizedBox(height: 24),
                _sectionHeader("Items (${items.length})"),
                const SizedBox(height: 12),
                ...items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.divider),
                      ),
                      padding: const EdgeInsets.all(14),
                      child: _buildCheckoutItem(item),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _sectionHeader("Summary"),
                const SizedBox(height: 12),
                _buildSummaryCard(subtotal),
              ],
            ),
      bottomNavigationBar: items.isEmpty
          ? null
          : SafeArea(
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: CustomButton(
                    text: "Place Order \u2022 Rs.$subtotal",
                    isLoading: _isPlacingOrder,
                    onPressed: cart != null ? () => _placeOrder(cart) : () {},
                    height: 56,
                    borderRadius: 12,
                  ),
                ),
              ),
            ),
    );
  }



  Widget _buildAddressField() {
    return GestureDetector(
      onTap: _showAddressPickerSheet,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: AbsorbPointer(
          child: TextField(
            controller: _addressController,
            maxLines: 3,
            minLines: 2,
            decoration: InputDecoration(
              hintText: "Tap to choose or search address",
              hintStyle: const TextStyle(color: AppColors.textSecondary),
              prefixIcon: const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Icon(Icons.location_on_outlined, color: AppColors.primary),
              ),
              suffixIcon: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Icon(Icons.chevron_right, color: AppColors.textSecondary),
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              filled: true,
              fillColor: AppColors.card,
              contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            ),
            style: const TextStyle(color: AppColors.textPrimary, height: 1.5),
            textCapitalization: TextCapitalization.sentences,
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentSelector() {
    final methods = ["Cash on Delivery", "eSewa(Pay on Delivery)", "Khalti(Pay on Delivery)"];
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: methods.map((method) {
          final isSelected = _selectedPayment == method;
          final isLast = method == methods.last;
          return InkWell(
            borderRadius: isLast
                ? const BorderRadius.vertical(bottom: Radius.circular(16))
                : BorderRadius.zero,
            onTap: () => setState(() => _selectedPayment = method),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                border: isLast ? null : Border(bottom: BorderSide(color: AppColors.divider)),
              ),
              child: Row(
                children: [
                  Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: isSelected ? AppColors.primary : AppColors.textSecondary, size: 22),
                  const SizedBox(width: 14),
                  Icon(method == "Cash on Delivery" ? Icons.money : Icons.payment, color: AppColors.primary, size: 22),
                  const SizedBox(width: 10),
                  Text(method, style: TextStyle(
                      color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal, fontSize: 15)),
                  const Spacer(),
                  if (isSelected)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primaryExtraLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text("Selected",
                          style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCheckoutItem(CartItemEntity item) {
    final imageUrl = item.imageUrl;
    final fullUrl = (imageUrl != null && imageUrl.trim().isNotEmpty)
        ? (imageUrl.startsWith('http')
            ? imageUrl
            : '${ApiEndpoints.mediaServerUrl}${imageUrl.startsWith('/') ? '' : '/'}$imageUrl')
        : null;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 64, height: 64,
            child: fullUrl != null
                ? Image.network(fullUrl, fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        color: AppColors.inputFill,
                        child: const Center(
                          child: SizedBox(width: 16, height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.inputFill,
                      child: const Icon(Icons.image_outlined, size: 28, color: AppColors.grey),
                    ),
                  )
                : Container(
                    color: AppColors.inputFill,
                    child: const Icon(Icons.image_outlined, size: 28, color: AppColors.grey),
                  ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.productName ?? "Product",
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text("Qty: ${item.quantity}", style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 4),
              Text("Rs. ${item.price ?? 0}",
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ),
        Text("Rs. ${(item.price ?? 0) * item.quantity}",
            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
      ],
    );
  }

  Widget _buildSummaryCard(int subtotal) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          _summaryRow("Subtotal", "Rs.$subtotal"),
          const SizedBox(height: 10),
          const _SummaryRow(title: "Delivery Fee", value: "FREE", valueColor: AppColors.primary),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              Text("Rs.$subtotal",
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimary));
  }

  Widget _summaryRow(String title, String value) {
    return Row(
      children: [
        Text(title, style: const TextStyle(color: AppColors.textSecondary)),
        const Spacer(),
        Text(value, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String title;
  final String value;
  final Color valueColor;
  const _SummaryRow({required this.title, required this.value, this.valueColor = AppColors.textPrimary});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: const TextStyle(color: AppColors.textSecondary)),
        const Spacer(),
        Text(value, style: TextStyle(color: valueColor, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  Address Picker Bottom Sheet
// ═══════════════════════════════════════════════════════════════

class _AddressPickerSheet extends StatefulWidget {
  final List<AddressEntity> savedAddresses;
  final AddressEntity? selectedAddress;
  final LatLng selectedLocation;

  /// Called when user confirms: (addressText, coordinates)
  final void Function(String address, LatLng location) onAddressPicked;

  const _AddressPickerSheet({
    required this.savedAddresses,
    this.selectedAddress,
    required this.selectedLocation,
    required this.onAddressPicked,
  });

  @override
  State<_AddressPickerSheet> createState() => _AddressPickerSheetState();
}

class _AddressPickerSheetState extends State<_AddressPickerSheet> {
  final _searchController = TextEditingController();
  final _mapController = MapController();
  final _geocoding = Geocoding();

  LatLng _location;
  String _addressText = '';
  bool _isSearching = false;
  bool _isDetectingLocation = false;
  List<Location> _searchResults = [];
  bool _isReversingGeocoding = false;
  String? _errorMessage;

  _AddressPickerSheetState()
      : _location = const LatLng(27.7172, 85.3240);

  @override
  void initState() {
    super.initState();
    _location = widget.selectedLocation;
    if (widget.selectedAddress != null) {
      _addressText = widget.selectedAddress!.fullAddress;
      _searchController.text = widget.selectedAddress!.fullAddress;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _searchLocation(String query) async {
    // Clear any previous error since the user is now searching
    setState(() => _errorMessage = null);

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
          _location = newLoc;
          _addressText = query;
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
      _location = newLoc;
      _addressText = _searchController.text.trim();
      _searchResults = [];
      _errorMessage = null;
    });
    _mapController.move(newLoc, 15);
  }

  Future<void> _detectCurrentLocation() async {
    setState(() => _isDetectingLocation = true);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() => _isDetectingLocation = false);
          _showSnackBar(
            'Please enable location services in your device settings.',
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () => Geolocator.openLocationSettings(),
            ),
          );
        }
        return;
      }

      // Check and request location permission
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            setState(() => _isDetectingLocation = false);
            _showSnackBar('Location permission is required to detect your address.');
          }
          return;
        }
      }

      // Handle permanently denied permission
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() => _isDetectingLocation = false);
          _showPermissionDeniedDialog();
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      if (!mounted) return;
      final newLoc = LatLng(position.latitude, position.longitude);
      setState(() {
        _location = newLoc;
        _isDetectingLocation = false;
        _addressText = '';
        _searchResults = [];
        _errorMessage = null;
      });
      _searchController.clear();
      _mapController.move(newLoc, 16);

      // Reverse geocode to get address name
      try {
        final placemarks = await _geocoding.placemarkFromCoordinates(
          position.latitude, position.longitude,
        );
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
          if (parts.isNotEmpty) {
            final addr = parts.join(', ');
            setState(() => _addressText = addr);
            _searchController.text = addr;
          }
        }
      } catch (_) {}
    } catch (_) {
      if (mounted) setState(() => _isDetectingLocation = false);
    }
  }

  void _selectFromSaved(AddressEntity address) {
    final loc = LatLng(address.latitude, address.longitude);
    setState(() {
      _location = loc;
      _addressText = address.fullAddress;
      _searchController.text = address.fullAddress;
      _searchResults = [];
      _errorMessage = null;
    });
    _mapController.move(loc, 15);
  }

  Future<void> _reverseGeocodeCurrentMapCenter() async {
    if (_isReversingGeocoding) return;
    setState(() => _isReversingGeocoding = true);
    try {
      final placemarks = await _geocoding.placemarkFromCoordinates(
        _location.latitude, _location.longitude,
      );
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
        if (parts.isNotEmpty) {
          setState(() => _addressText = parts.join(', '));
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _isReversingGeocoding = false);
  }

  void _confirmAddress() {
    // Use search text as the address, or the reverse-geocoded text
    final text = _searchController.text.trim().isNotEmpty
        ? _searchController.text.trim()
        : _addressText;

    if (text.isEmpty) {
      setState(() => _errorMessage = 'Please search for a place, select a saved address, or use current location.');
      return;
    }

    setState(() => _errorMessage = null);
    widget.onAddressPicked(text, _location);
    Navigator.pop(context);
  }

  void _showSnackBar(String message, {SnackBarAction? action}) {
    if (!mounted) return;
    // Also set inline error so the user sees it inside the sheet
    setState(() => _errorMessage = message);
    SnackbarUtils.showError(
      context,
      message,
      duration: const Duration(seconds: 4),
      action: action,
    );
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Text("Choose Delivery Address",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 16),

            // Search bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search for a place...",
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                suffixIcon: _isSearching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(width: 18, height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    : (_searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchResults = [];
                              });
                            },
                          )
                        : null),
                filled: true,
                fillColor: AppColors.inputFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              ),
              onChanged: _searchLocation,
              textInputAction: TextInputAction.search,
            ),
            const SizedBox(height: 10),

            // Search results list
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
                  separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.divider),
                  itemBuilder: (context, index) {
                    final loc = _searchResults[index];
                    final isSelected = _location.latitude == loc.latitude && _location.longitude == loc.longitude;
                    return InkWell(
                      onTap: () => _selectSearchResult(index),
                      borderRadius: index == 0
                          ? const BorderRadius.vertical(top: Radius.circular(12))
                          : index == _searchResults.length - 1
                              ? const BorderRadius.vertical(bottom: Radius.circular(12))
                              : BorderRadius.zero,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        child: Row(
                          children: [
                            Icon(Icons.location_on_outlined,
                                size: 18, color: isSelected ? AppColors.primary : AppColors.textSecondary),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _searchController.text,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                            ),
                            Text(
                              "${loc.latitude.toStringAsFixed(4)}, ${loc.longitude.toStringAsFixed(4)}",
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            if (_searchResults.isNotEmpty) const SizedBox(height: 10),

            // Use Current Location button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isDetectingLocation ? null : _detectCurrentLocation,
                icon: _isDetectingLocation
                    ? const SizedBox(width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.my_location, color: AppColors.primary),
                label: Text(
                  _isDetectingLocation ? "Detecting..." : "Use My Current Location",
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Saved addresses
            if (widget.savedAddresses.isNotEmpty) ...[
              const Text("Saved Addresses",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              SizedBox(
                height: 72,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.savedAddresses.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final addr = widget.savedAddresses[index];
                    final icon = _getAddrIcon(addr.label);
                    final color = _getAddrColor(addr.label);
                    return GestureDetector(
                      onTap: () => _selectFromSaved(addr),
                      child: Container(
                        width: 140,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: color.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(icon, size: 14, color: color),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(addr.label,
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Expanded(
                              child: Text(addr.fullAddress, maxLines: 2, overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, height: 1.3)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Map
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 180,
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _location,
                        initialZoom: 15,
                        onMapEvent: (MapEvent event) {
                          if (event is MapEventMoveEnd) {
                            setState(() {
                              _location = _mapController.camera.center;
                              // Clear address so user can reverse-geocode or re-search
                              if (_addressText.isNotEmpty &&
                                  _searchController.text.isNotEmpty &&
                                  !_isReversingGeocoding) {
                                // Optionally reverse-geocode silently
                              }
                            });
                            _reverseGeocodeCurrentMapCenter();
                          }
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.localkart.app',
                        ),
                      ],
                    ),
                    IgnorePointer(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(width: 12, height: 4,
                                decoration: BoxDecoration(color: AppColors.black.withOpacity(0.26), borderRadius: BorderRadius.circular(2))),
                            const SizedBox(height: 2),
                            const Icon(Icons.location_on, size: 40, color: AppColors.primary),
                          ],
                        ),
                      ),
                    ),
                    if (_isReversingGeocoding || _isDetectingLocation)
                      Container(
                        color: AppColors.black.withOpacity(0.26),
                        child: const Center(child: CircularProgressIndicator(color: AppColors.white)),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Address preview
            if (_addressText.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryExtraLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_addressText,
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, height: 1.4)),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // Inline error message (visible, unlike a snackbar behind the sheet)
            if (_errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 18, color: AppColors.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Confirm button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _confirmAddress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Confirm Address",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  IconData _getAddrIcon(String label) {
    switch (label.toLowerCase()) {
      case 'home': return Icons.home_rounded;
      case 'work': return Icons.work_rounded;
      default: return Icons.location_on_rounded;
    }
  }

  Color _getAddrColor(String label) {
    switch (label.toLowerCase()) {
      case 'home': return AppColors.primary;
      case 'work': return AppColors.warning;
      default: return AppColors.textSecondary;
    }
  }
}
