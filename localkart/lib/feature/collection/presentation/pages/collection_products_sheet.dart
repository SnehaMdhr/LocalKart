import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/app/theme/app_colors.dart';
import 'package:localkart/core/api/api_endpoints.dart';
import 'package:localkart/core/utils/snackbar_utils.dart';
import 'package:localkart/feature/cart/presentation/states/cart_state.dart';
import 'package:localkart/feature/cart/presentation/view_model/cart_view_model.dart';
import 'package:localkart/feature/collection/domain/entities/collection_entity.dart';
import 'package:localkart/feature/product/domain/entities/product_entity.dart';

/// Helper function to show the collection products dialog.
void showCollectionProductsDialog(
  BuildContext context, {
  required CollectionEntity collection,
  required List<ProductEntity> products,
}) {
  showDialog(
    context: context,
    builder: (_) => CollectionProductsDialog(
      collection: collection,
      products: products,
    ),
  );
}

class CollectionProductsDialog extends ConsumerStatefulWidget {
  final CollectionEntity collection;
  final List<ProductEntity> products;

  const CollectionProductsDialog({
    super.key,
    required this.collection,
    required this.products,
  });

  @override
  ConsumerState<CollectionProductsDialog> createState() =>
      _CollectionProductsDialogState();
}

class _CollectionProductsDialogState
    extends ConsumerState<CollectionProductsDialog> {
  bool _isAddingAll = false;

  /// Track which products are currently being added.
  final Set<String> _addingProductIds = {};

  Future<void> _addToCart(ProductEntity product) async {
    final productId = product.productId;
    if (productId == null || productId.trim().isEmpty) return;

    setState(() => _addingProductIds.add(productId));

    await ref.read(cartViewModelProvider.notifier).addToCart(
      productId,
      quantity: 1,
    );

    setState(() => _addingProductIds.remove(productId));

    if (mounted) {
      final cartState = ref.read(cartViewModelProvider);
      if (cartState.status == CartStatus.loaded) {
        SnackbarUtils.showSuccess(
          context,
          "Added ${product.productName} to cart",
          duration: const Duration(seconds: 2),
        );
      } else {
        SnackbarUtils.showError(
          context,
          cartState.errorMessage ?? "Failed to add to cart",
        );
      }
    }
  }

  void _confirmAddAll() {
    final productCount = widget.products.length;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          "Add All to Cart",
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          "Add all $productCount item${productCount == 1 ? '' : 's'} to your cart?",
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              "Cancel",
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _addAllToCart();
            },
            child: const Text(
              "Add All",
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addAllToCart() async {
    setState(() => _isAddingAll = true);

    int addedCount = 0;
    int failedCount = 0;

    for (final product in widget.products) {
      final productId = product.productId;
      if (productId == null || productId.trim().isEmpty) {
        failedCount++;
        continue;
      }

      setState(() => _addingProductIds.add(productId));

      await ref.read(cartViewModelProvider.notifier).addToCart(
        productId,
        quantity: 1,
      );

      setState(() => _addingProductIds.remove(productId));

      if (mounted) {
        final cartState = ref.read(cartViewModelProvider);
        if (cartState.status == CartStatus.loaded) {
          addedCount++;
        } else {
          failedCount++;
        }
      }
    }

    setState(() => _isAddingAll = false);

    if (mounted) {
      if (failedCount > 0) {
        SnackbarUtils.showWarning(
          context,
          "Added $addedCount item${addedCount == 1 ? '' : 's'} ($failedCount failed)",
          duration: const Duration(seconds: 3),
        );
      } else {
        SnackbarUtils.showSuccess(
          context,
          "Added all $addedCount item${addedCount == 1 ? '' : 's'} to cart!",
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartViewModelProvider);

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
            // Header with title and close button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
              child: Row(
                children: [
                  const Icon(
                    Icons.collections_bookmark_outlined,
                    color: AppColors.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.collection.collectionName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryExtraLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "${widget.products.length} item${widget.products.length == 1 ? '' : 's'}",
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                    splashRadius: 20,
                    tooltip: "Close",
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.fromLTRB(20, 2, 20, 0),
              child: Text(
                "Tap + to add items or add all at once",
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ),

            const SizedBox(height: 12),

            // Add All button
            if (widget.products.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: _isAddingAll ? null : _confirmAddAll,
                    icon: _isAddingAll
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.add_shopping_cart, size: 18),
                    label: Text(
                      _isAddingAll ? "Adding all..." : "Add All to Cart",
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ),

            if (widget.products.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Divider(color: AppColors.divider, height: 1),
              ),
              const SizedBox(height: 6),
            ],

            // Products list
            Flexible(
              child: widget.products.isEmpty
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
                              "No products in this collection",
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
                      itemCount: widget.products.length,
                      itemBuilder: (context, index) {
                        final product = widget.products[index];
                        final productId = product.productId ?? '';
                        final isInCart =
                            productId.isNotEmpty &&
                            cartState.cart?.items.any(
                                  (item) => item.productId == productId,
                                ) ==
                                true;
                        final isAdding =
                            _addingProductIds.contains(productId);

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: _buildProductTile(
                            product,
                            isInCart,
                            isAdding,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductTile(
    ProductEntity product,
    bool isInCart,
    bool isAdding,
  ) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isInCart
                ? AppColors.primary.withValues(alpha: 0.3)
                : AppColors.divider,
          ),
        ),
        child: Row(
          children: [
            // Product image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 56,
                height: 56,
                child: _buildProductImage(product),
              ),
            ),
            const SizedBox(width: 12),

            // Product details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.productName,
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
                    product.unit,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Rs. ${product.price}",
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),

            // Add to Cart button
            if (isInCart)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryExtraLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppColors.primary,
                      size: 12,
                    ),
                    SizedBox(width: 3),
                    Text(
                      "In Cart",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            else
              SizedBox(
                width: 36,
                height: 36,
                child: ElevatedButton(
                  onPressed: isAdding ? null : () => _addToCart(product),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: isAdding
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.add, size: 18),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(ProductEntity product) {
    final imageUrl = product.imageUrl;

    if (imageUrl == null || imageUrl.trim().isEmpty) {
      return Container(
        color: AppColors.inputFill,
        child: const Icon(
          Icons.image_outlined,
          color: AppColors.grey,
          size: 24,
        ),
      );
    }

    final fullUrl = imageUrl.startsWith('http')
        ? imageUrl
        : '${ApiEndpoints.mediaServerUrl}${imageUrl.startsWith('/') ? '' : '/'}$imageUrl';

    return Image.network(
      fullUrl,
      width: 56,
      height: 56,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: AppColors.inputFill,
          child: const Center(
            child: SizedBox(
              width: 14,
              height: 14,
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
            Icons.broken_image_outlined,
            color: AppColors.grey,
            size: 24,
          ),
        );
      },
    );
  }
}
