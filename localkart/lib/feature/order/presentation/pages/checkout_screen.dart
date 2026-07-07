import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/app/theme/app_colors.dart';
import 'package:localkart/core/api/api_endpoints.dart';
import 'package:localkart/core/widgets/custom_button.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter your delivery address"),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
          ),
        ),
      );
      return;
    }

    setState(() => _isPlacingOrder = true);

    // Use default coordinates since we don't have a map picker
    const defaultLatitude = 27.7172;
    const defaultLongitude = 85.3240;

    final order = await ref.read(orderViewModelProvider.notifier).placeOrder(
      deliveryAddress: address,
      latitude: defaultLatitude,
      longitude: defaultLongitude,
      paymentMethod: _selectedPayment,
    );

    if (!mounted) return;
    setState(() => _isPlacingOrder = false);

    if (order != null) {
      // Navigate to order status screen on success
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OrderStatusScreen(order: order),
        ),
      );
      // Refresh the cart (it was cleared by the backend)
      ref.read(cartViewModelProvider.notifier).getCart();
    } else {
      // Show error from state in a dialog (harder to miss than a snackbar)
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
                /// Section: Delivery Address
                _sectionHeader("Delivery Address"),
                const SizedBox(height: 12),
                _buildAddressField(),
                const SizedBox(height: 24),

                /// Section: Payment Method
                _sectionHeader("Payment Method"),
                const SizedBox(height: 12),
                _buildPaymentSelector(),
                const SizedBox(height: 24),

                /// Section: Order Items
                _sectionHeader("Items (${items.length})"),
                const SizedBox(height: 12),
                ...items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildCheckoutItem(item),
                  ),
                ),
                const SizedBox(height: 24),

                /// Section: Summary
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
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: CustomButton(
                    text: "Place Order • Rs.$subtotal",
                    isLoading: _isPlacingOrder,
                    onPressed: cart != null
                        ? () => _placeOrder(cart)
                        : () {},
                    height: 56,
                    borderRadius: 12,
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildAddressField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: TextField(
        controller: _addressController,
        maxLines: 3,
        minLines: 2,
        decoration: InputDecoration(
          hintText: "Enter your delivery address",
          hintStyle: const TextStyle(color: AppColors.textSecondary),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Icon(Icons.location_on_outlined, color: AppColors.primary),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppColors.card,
          contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        ),
        style: const TextStyle(color: AppColors.textPrimary, height: 1.5),
        textCapitalization: TextCapitalization.sentences,
      ),
    );
  }

  Widget _buildPaymentSelector() {
    final methods = ["Cash on Delivery", "eSewa"];

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
                border: isLast
                    ? null
                    : Border(bottom: BorderSide(color: AppColors.divider)),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    size: 22,
                  ),
                  const SizedBox(width: 14),
                  Icon(
                    method == "Cash on Delivery"
                        ? Icons.money
                        : Icons.payment,
                    color: AppColors.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    method,
                    style: TextStyle(
                      color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 15,
                    ),
                  ),
                  const Spacer(),
                  if (isSelected)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primaryExtraLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        "Selected",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
            width: 64,
            height: 64,
            child: fullUrl != null
                ? Image.network(
                    fullUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        color: AppColors.inputFill,
                        child: const Center(
                          child: SizedBox(
                            width: 16, height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.inputFill,
                        child: const Icon(Icons.image_outlined, size: 28, color: AppColors.grey),
                      );
                    },
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
              Text(
                item.productName ?? "Product",
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Qty: ${item.quantity}",
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                "Rs. ${item.price ?? 0}",
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        Text(
          "Rs. ${(item.price ?? 0) * item.quantity}",
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
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
          const _SummaryRow(
            title: "Delivery Fee",
            value: "FREE",
            valueColor: AppColors.primary,
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              Text(
                "Rs.$subtotal",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _summaryRow(String title, String value) {
    return Row(
      children: [
        Text(title, style: const TextStyle(color: AppColors.textSecondary)),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String title;
  final String value;
  final Color valueColor;

  const _SummaryRow({
    required this.title,
    required this.value,
    this.valueColor = AppColors.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: const TextStyle(color: AppColors.textSecondary)),
        const Spacer(),
        Text(
          value,
          style: TextStyle(color: valueColor, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
