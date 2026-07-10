import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/app/theme/app_colors.dart';
import 'package:localkart/core/api/api_endpoints.dart';
import 'package:localkart/core/utils/snackbar_utils.dart';
import 'package:localkart/core/widgets/custom_button.dart';
import 'package:localkart/feature/cart/domain/entities/cart_entity.dart';
import 'package:localkart/feature/cart/presentation/states/cart_state.dart';
import 'package:localkart/feature/cart/presentation/view_model/cart_view_model.dart';
import 'package:localkart/feature/order/presentation/pages/checkout_screen.dart';
import 'package:localkart/feature/order/presentation/view_model/order_view_model.dart';

class CartDetailScreen extends ConsumerStatefulWidget {
  const CartDetailScreen({super.key});

  @override
  ConsumerState<CartDetailScreen> createState() => _CartDetailScreenState();
}

class _CartDetailScreenState extends ConsumerState<CartDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(cartViewModelProvider.notifier).getCart();
    });
    Future.microtask(() {
      ref.read(orderViewModelProvider.notifier).getMyOrders();
    });
  }

  int _calculateSubtotal(CartEntity cart) {
    return cart.items.fold<int>(
      0,
      (sum, item) => sum + ((item.price ?? 0) * item.quantity),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartViewModelProvider);
    final cart = cartState.cart;
    final items = cart?.items ?? [];
    final subtotal = cart != null ? _calculateSubtotal(cart) : 0;
    final orderState = ref.watch(orderViewModelProvider);
    final orders = orderState.orders ?? [];

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
          "My Cart",
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: AppColors.card,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Text(
                      "Clear Cart",
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    content: const Text(
                      "Remove all items from your cart?",
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text(
                          "Clear",
                          style: TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
                if (confirmed == true && mounted) {
                  await ref.read(cartViewModelProvider.notifier).clearCart();
                  if (mounted) {
                    SnackbarUtils.showSuccess(context, "Cart cleared");
                  }
                }
              },
            ),
        ],
      ),
      body: _buildBody(cartState, items, subtotal),
    );
  }

  Widget _buildBody(
    CartState cartState,
    List<CartItemEntity> items,
    int subtotal,
  ) {
    if (cartState.status == CartStatus.loading && items.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (cartState.status == CartStatus.error && items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 56, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                cartState.errorMessage ?? "Failed to load cart",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  ref.read(cartViewModelProvider.notifier).getCart();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Retry",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.shopping_cart_outlined,
                size: 72,
                color: AppColors.grey,
              ),
              const SizedBox(height: 16),
              const Text(
                "Your cart is empty",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Browse products and add items to get started",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Start Shopping",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
            children: [
              ...items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: _buildCartItem(item),
                ),
              ),
              const SizedBox(height: 8),
              // const Text(
              //   "Have a coupon?",
              //   style: TextStyle(
              //     fontWeight: FontWeight.w600,
              //     color: AppColors.textPrimary,
              //   ),
              // ),
              // const SizedBox(height: 12),
              // Row(
              //   children: [
              //     Expanded(
              //       child: TextField(
              //         decoration: InputDecoration(
              //           hintText: "Enter code",
              //           filled: true,
              //           fillColor: AppColors.white,
              //           contentPadding:
              //               const EdgeInsets.symmetric(horizontal: 16),
              //           enabledBorder: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(30),
              //             borderSide:
              //                 const BorderSide(color: AppColors.border),
              //           ),
              //           focusedBorder: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(30),
              //             borderSide:
              //                 const BorderSide(color: AppColors.primary),
              //           ),
              //         ),
              //       ),
              //     ),
              //     const SizedBox(width: 10),
              //     SizedBox(
              //       width: 96,
              //       height: 56,
              //       child: ElevatedButton(
              //         onPressed: () {},
              //         style: ElevatedButton.styleFrom(
              //           backgroundColor: Colors.grey.shade600,
              //           minimumSize: const Size(96, 56),
              //           shape: RoundedRectangleBorder(
              //             borderRadius: BorderRadius.circular(30),
              //           ),
              //         ),
              //         child: const Text("Apply"),
              //       ),
              //     ),
              //   ],
              // ),
              const SizedBox(height: 25),
              const Divider(),
              const SizedBox(height: 15),
              _summaryRow("Subtotal", "Rs.$subtotal"),
              const SizedBox(height: 10),
              _summaryRow(
                "Delivery Fee",
                "FREE",
                valueColor: AppColors.primary,
              ),
              const Divider(height: 35),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total Amount",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Rs.$subtotal",
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(18),
          child: SizedBox(
            width: double.infinity,
            height: 58,
            child: CustomButton(
              text: "Proceed to Checkout",
              onPressed: () {
                Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CheckoutScreen()),
          );
              },
              height: 56,
              borderRadius: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCartItem(CartItemEntity item) {
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
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            width: 82,
            height: 82,
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
                            width: 20,
                            height: 20,
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
                        child: const Icon(
                          Icons.image_outlined,
                          size: 36,
                          color: AppColors.grey,
                        ),
                      );
                    },
                  )
                : Container(
                    color: AppColors.inputFill,
                    child: const Icon(
                      Icons.image_outlined,
                      size: 36,
                      color: AppColors.grey,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.productName ?? "Product",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      await ref
                          .read(cartViewModelProvider.notifier)
                          .removeFromCart(item.productId);
                      if (mounted) {
                        SnackbarUtils.showError(
                          context,
                          "${item.productName} removed from cart",
                          duration: const Duration(seconds: 2),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    "Rs. ${item.price ?? 0}",
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryExtraLight,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () async {
                            if (item.quantity <= 1) {
                              await ref
                                  .read(cartViewModelProvider.notifier)
                                  .removeFromCart(item.productId);
                              if (mounted) {
                                SnackbarUtils.showError(
                                  context,
                                  "${item.productName} removed from cart",
                                  duration: const Duration(seconds: 2),
                                );
                              }
                            } else {
                              await ref
                                  .read(cartViewModelProvider.notifier)
                                  .updateQuantity(
                                    item.productId,
                                    item.quantity - 1,
                                  );
                              if (mounted) {
                                SnackbarUtils.showInfo(
                                  context,
                                  "Quantity updated",
                                  duration: const Duration(seconds: 1),
                                );
                              }
                            }
                          },
                          icon: const Icon(
                            Icons.remove,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        Text(
                          "${item.quantity}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            await ref
                                .read(cartViewModelProvider.notifier)
                                .updateQuantity(
                                  item.productId,
                                  item.quantity + 1,
                                );
                            if (mounted) {
                              SnackbarUtils.showInfo(
                                context,
                                "Quantity updated",
                                duration: const Duration(seconds: 1),
                              );
                            }
                          },
                          icon: const CircleAvatar(
                            radius: 13,
                            backgroundColor: AppColors.primary,
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(
    String title,
    String value, {
    Color valueColor = AppColors.textPrimary,
  }) {
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
