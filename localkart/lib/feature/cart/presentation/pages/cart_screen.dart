import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/app/theme/app_colors.dart';
import 'package:localkart/feature/cart/presentation/pages/cart_detail_screen.dart';
import 'package:localkart/feature/cart/domain/entities/cart_entity.dart';
import 'package:localkart/feature/cart/presentation/view_model/cart_view_model.dart';
import 'package:localkart/feature/collection/domain/entities/collection_entity.dart';
import 'package:localkart/feature/collection/presentation/view_model/collection_view_model.dart';
import 'package:localkart/feature/collection/presentation/pages/collection_screen.dart';
import 'package:localkart/feature/order/domain/entities/order_entity.dart';
import 'package:localkart/feature/order/presentation/pages/order_detail_screen.dart';
import 'package:localkart/feature/order/presentation/states/order_state.dart';
import 'package:localkart/feature/order/presentation/view_model/order_view_model.dart';
import 'package:localkart/feature/product/domain/entities/product_entity.dart';
import 'package:localkart/feature/product/presentation/view_model/product_view_model.dart';
import 'package:localkart/feature/collection/presentation/pages/collection_products_sheet.dart';
import 'package:localkart/feature/order/presentation/pages/reorder_bottom_sheet.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(cartViewModelProvider.notifier).getCart();
    });
    Future.microtask(() {
      ref.read(collectionViewModelProvider.notifier).getAllCollections();
    });
    Future.microtask(() {
      ref.read(productViewModelProvider.notifier).getAllProducts();
    });
    Future.microtask(() {
      ref.read(orderViewModelProvider.notifier).getMyOrders();
    });
  }

  int _calculateItemCount(CartEntity cart) {
    return cart.items.fold(0, (sum, item) => sum + item.quantity);
  }

  int _calculateTotalPrice(CartEntity cart) {
    return cart.items.fold<int>(
      0,
      (sum, item) => sum + ((item.price ?? 0) * item.quantity),
    );
  }


  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartViewModelProvider);
    final cart = cartState.cart;
    final itemCount = cart != null ? _calculateItemCount(cart) : 0;
    final totalPrice = cart != null ? _calculateTotalPrice(cart) : 0;

    final collectionState = ref.watch(collectionViewModelProvider);
    final collections = collectionState.collections;

    final productState = ref.watch(productViewModelProvider);
    final allProducts = productState.products;

    final orderState = ref.watch(orderViewModelProvider);
    final orders = orderState.orders ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _cartSummary(context, itemCount, totalPrice),

            const SizedBox(height: 28),

            _sectionHeader(
              "My Collections",
              "See All",
              onAction: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CollectionScreen()),
                );
              },
            ),

            const SizedBox(height: 14),

            _buildCollectionsSection(collections, allProducts),

            const SizedBox(height: 30),

            _sectionHeader("Previous Orders", "History"),

            const SizedBox(height: 14),

            if (orders.isEmpty && orderState.status == OrderStatus.loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))),
              )
            else if (orders.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24),
                alignment: Alignment.center,
                child: const Text(
                  "No previous orders",
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
              )
            else
              ...orders.map(
                (order) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _orderCard(order),
                ),
              ),
          ],
        ),
      ),
    );
  }

  int _calculateCollectionPrice(
    CollectionEntity collection,
    List<ProductEntity> allProducts,
  ) {
    if (collection.productIds.isEmpty || allProducts.isEmpty) return 0;
    return allProducts
        .where(
          (p) =>
              p.productId != null &&
              collection.productIds.contains(p.productId),
        )
        .fold<int>(0, (sum, p) => sum + p.price);
  }

  Widget _buildCollectionsSection(
    List<CollectionEntity> collections,
    List<ProductEntity> allProducts,
  ) {
    if (collections.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        alignment: Alignment.center,
        child: const Text(
          "No collections yet",
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
      );
    }

    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: collections.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (_, index) {
          final collection = collections[index];
          final totalPrice = _calculateCollectionPrice(collection, allProducts);
          return _collectionCard(collection, totalPrice, allProducts);
        },
      ),
    );
  }

  Widget _cartSummary(BuildContext context, int itemCount, int totalPrice) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CartDetailScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.shopping_cart,
                color: AppColors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "My Cart",
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    itemCount > 0
                        ? "$itemCount item${itemCount == 1 ? '' : 's'} \u2022 Rs. $totalPrice"
                        : "No items yet",
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, String action, {VoidCallback? onAction}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        TextButton(
          onPressed: onAction ?? () {},
          child: Text(action, style: const TextStyle(color: AppColors.primary)),
        ),
      ],
    );
  }

  Widget _collectionCard(CollectionEntity collection, int totalPrice, List<ProductEntity> allProducts) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.03), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.collections_bookmark_outlined,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  collection.collectionName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            "${collection.productIds.length} product${collection.productIds.length == 1 ? '' : 's'}",
            style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
          ),

          const Spacer(),

          Row(
            children: [
              Text(
                "Rs. $totalPrice",
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  final products = allProducts
                      .where((p) =>
                          p.productId != null &&
                          collection.productIds.contains(p.productId))
                      .toList();
                  showCollectionProductsDialog(
                    context,
                    collection: collection,
                    products: products,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryExtraLight,
                  foregroundColor: AppColors.primary,
                  minimumSize: const Size(80, 42),
                  elevation: 0,
                ),
                child: const Text("View"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _orderCard(OrderEntity order) {
    final shortId = (order.orderId ?? '').length >= 8
        ? (order.orderId ?? '').substring(0, 8).toUpperCase()
        : (order.orderId ?? '').toUpperCase();

    Color statusBgColor, statusTextColor;
    switch (order.status) {
      case "Pending":
        statusBgColor = AppColors.warning.withOpacity(0.15);
        statusTextColor = AppColors.warning;
        break;
      case "Accepted":
      case "Preparing":
      case "Out for Delivery":
        statusBgColor = const Color(0xFFE3F5E8);
        statusTextColor = AppColors.primary;
        break;
      case "Delivered":
        statusBgColor = AppColors.success.withOpacity(0.15);
        statusTextColor = AppColors.success;
        break;
      case "Rejected":
      case "Cancelled":
        statusBgColor = const Color(0xFFFFEEEE);
        statusTextColor = AppColors.error;
        break;
      default:
        statusBgColor = AppColors.inputFill;
        statusTextColor = AppColors.textSecondary;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OrderDetailScreen(order: order),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _formatDate(order.createdAt ?? ''),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.status,
                    style: TextStyle(
                      color: statusTextColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: Text(
                    "Order #$shortId",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Rs. ${order.totalAmount}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${order.items.length} item${order.items.length != 1 ? 's' : ''}",
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => ReorderDialog.show(context, order),
                  icon: const Icon(Icons.replay, size: 18),
                  label: const Text("Reorder"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryExtraLight,
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                    minimumSize: const Size(120, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
      final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
      final amPm = date.hour >= 12 ? "PM" : "AM";
      final minute = date.minute.toString().padLeft(2, '0');
      return "${date.day} ${months[date.month - 1]}, ${date.year} \u2022 $hour:$minute $amPm";
    } catch (_) {
      return dateStr;
    }
  }
}
