import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/app/theme/app_colors.dart';
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: AppColors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        duration: const Duration(seconds: 3),
      ),
    );
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
  String _selectedLabel = 'Home';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController(
      text: widget.isEditing ? widget.address?.fullAddress : '',
    );
    if (widget.isEditing && widget.address != null) {
      _selectedLabel = widget.address!.label;
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
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
            const SizedBox(height: 24),

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
                        padding: const EdgeInsets.symmetric(vertical: 14),
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
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
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
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppColors.white),
                        ),
                      )
                    : Text(
                        widget.isEditing ? "Update Address" : "Save Address",
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
            latitude: widget.address!.latitude,
            longitude: widget.address!.longitude,
          );
    } else {
      // Default coordinates (Kathmandu) — user can update later via edit
      ref.read(addressViewModelProvider.notifier).createAddress(
            label: _selectedLabel,
            fullAddress: addressText,
            latitude: 27.7172,
            longitude: 85.3240,
          );
    }

    // Close the modal immediately so the user sees the loading state on the main screen
    Navigator.pop(context);
  }
}
