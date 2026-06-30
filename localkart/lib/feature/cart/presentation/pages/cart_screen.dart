import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/app/theme/app_colors.dart';
import 'package:localkart/feature/cart/presentation/pages/cart_detail_screen.dart';
import 'package:localkart/feature/cart/domain/entities/cart_entity.dart';
import 'package:localkart/feature/cart/presentation/view_model/cart_view_model.dart';
import 'package:localkart/feature/collection/domain/entities/collection_entity.dart';
import 'package:localkart/feature/collection/presentation/view_model/collection_view_model.dart';
import 'package:localkart/feature/collection/presentation/pages/collection_screen.dart';
import 'package:localkart/feature/product/domain/entities/product_entity.dart';
import 'package:localkart/feature/product/presentation/view_model/product_view_model.dart';
import 'package:localkart/feature/collection/presentation/pages/collection_products_sheet.dart';

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

  static const List<Map<String, String>> orders = [
    {"date": "10 Oct, 2023 • 06:20 PM", "id": "#LK-8412", "price": "Rs 180"},
    {"date": "15 Oct, 2023 • 01:45 PM", "id": "#LK-8421", "price": "Rs 560"},
    {"date": "22 Oct, 2023 • 09:10 AM", "id": "#LK-8450", "price": "Rs 990"},
  ];

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

  Widget _orderCard(Map<String, String> order) {
    return Container(
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
                  order["date"]!,
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
                  color: AppColors.inputFill,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Completed",
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
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
                  "Order ${order["id"]}",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Text(
                order["price"]!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: AppColors.primary,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text("Reorder"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryExtraLight,
                  foregroundColor: AppColors.primary,
                  elevation: 0,
                  minimumSize: const Size(120, 44),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
