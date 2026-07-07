import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/app/theme/app_colors.dart';
import 'package:localkart/core/api/api_endpoints.dart';
import 'package:localkart/core/widgets/custom_button.dart';
import 'package:localkart/feature/cart/presentation/view_model/cart_view_model.dart';
import 'package:localkart/feature/order/domain/entities/order_entity.dart';
import 'package:localkart/feature/order/presentation/pages/checkout_screen.dart';

class ReorderDialog extends ConsumerStatefulWidget {
  final OrderEntity order;

  const ReorderDialog({super.key, required this.order});

  static Future<void> show(BuildContext context, OrderEntity order) {
    return showDialog(
      context: context,
      builder: (_) => ReorderDialog(order: order),
    );
  }

  @override
  ConsumerState<ReorderDialog> createState() => _ReorderDialogState();
}

class _ReorderDialogState extends ConsumerState<ReorderDialog> {
  late List<OrderItemEntity> _items;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.order.items);
  }

  int get _totalAmount {
    return _items.fold<int>(0, (sum, item) => sum + ((item.price ?? 0) * item.quantity));
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  Future<void> _proceedToCheckout() async {
    if (_items.isEmpty) return;

    // Dismiss the dialog
    Navigator.pop(context);

    // Add each remaining item to the cart
    for (final item in _items) {
      await ref.read(cartViewModelProvider.notifier).addToCart(
        item.productId,
        quantity: item.quantity,
      );
    }

    // Navigate to checkout screen
    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CheckoutScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryExtraLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.replay,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Reorder Items",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "${_items.length} item${_items.length != 1 ? 's' : ''} selected",
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                    splashRadius: 20,
                    tooltip: "Close",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ── Divider ──
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Divider(color: AppColors.divider, height: 1),
            ),

            const SizedBox(height: 4),

            // ── Items List ──
            Flexible(
              child: _items.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 40,
                              color: AppColors.grey,
                            ),
                            SizedBox(height: 10),
                            Text(
                              "No items selected",
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      itemCount: _items.length,
                      itemBuilder: (_, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: _buildItemTile(_items[index], index),
                        );
                      },
                    ),
            ),

            // ── Bottom section (always visible) ──
            if (_items.isNotEmpty)
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Text(
                            "Total Amount",
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            "Rs. $_totalAmount",
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 26,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: CustomButton(
                          text: "Add to Cart",
                          onPressed: _proceedToCheckout,
                          height: 56,
                          borderRadius: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemTile(OrderItemEntity item, int index) {
    final imageUrl = item.imageUrl;
    final fullUrl = (imageUrl != null && imageUrl.trim().isNotEmpty)
        ? (imageUrl.startsWith('http')
              ? imageUrl
              : '${ApiEndpoints.mediaServerUrl}${imageUrl.startsWith('/') ? '' : '/'}$imageUrl')
        : null;

    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            // Product image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 56,
                height: 56,
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
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
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
            const SizedBox(width: 12),

            // Item details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName ?? "Product",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Qty: ${item.quantity}",
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Rs. ${item.price ?? 0}",
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),

            // Line total
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                "Rs. ${(item.price ?? 0) * item.quantity}",
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),

            // Delete icon
            IconButton(
              onPressed: () => _removeItem(index),
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.error,
                size: 22,
              ),
              splashRadius: 20,
              tooltip: "Remove item",
            ),
          ],
        ),
      ),
    );
  }
}
