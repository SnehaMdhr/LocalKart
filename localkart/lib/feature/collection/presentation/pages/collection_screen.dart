import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/app/theme/app_colors.dart';
import 'package:localkart/core/api/api_endpoints.dart';
import 'package:localkart/core/utils/snackbar_utils.dart';
import 'package:localkart/feature/collection/domain/entities/collection_entity.dart';
import 'package:localkart/feature/collection/presentation/pages/collection_products_sheet.dart';
import 'package:localkart/feature/collection/presentation/states/collection_state.dart';
import 'package:localkart/feature/collection/presentation/view_model/collection_view_model.dart';
import 'package:localkart/feature/product/domain/entities/product_entity.dart';
import 'package:localkart/feature/product/presentation/view_model/product_view_model.dart';

class CollectionScreen extends ConsumerStatefulWidget {
  const CollectionScreen({super.key});

  @override
  ConsumerState<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends ConsumerState<CollectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    Future.microtask(() {
      ref.read(collectionViewModelProvider.notifier).getAllCollections();
      ref.read(productViewModelProvider.notifier).getAllProducts();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _showCreateCollectionDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController();
        var isCreating = false;
        return StatefulBuilder(
          builder: (_, setDialogState) => AlertDialog(
            backgroundColor: AppColors.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                const Icon(Icons.favorite, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  isCreating ? "Creating..." : "New Collection",
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              ],
            ),
            content: isCreating
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : TextField(
                    controller: controller,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: "e.g. Groceries, Snacks...",
                      hintStyle: const TextStyle(
                          color: AppColors.textSecondary),
                      filled: true,
                      fillColor: AppColors.inputFill,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 1.5),
                      ),
                    ),
                    style: const TextStyle(
                        color: AppColors.textPrimary),
                    onSubmitted: (value) async {
                      final name = value.trim();
                      if (name.isNotEmpty) {
                        setDialogState(() => isCreating = true);
                        await ref
                            .read(collectionViewModelProvider.notifier)
                            .createCollection(name);
                        if (!context.mounted) return;
                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                          SnackbarUtils.showSuccess(
                            context,
                            'Collection "$name" created!',
                          );
                        }
                      }
                    },
                  ),
            actions: [
              if (!isCreating)
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                        color: AppColors.textSecondary),
                  ),
                ),
              TextButton(
                onPressed: isCreating
                    ? null
                    : () async {
                        final name = controller.text.trim();
                        if (name.isNotEmpty) {
                          setDialogState(() => isCreating = true);
                          await ref
                              .read(collectionViewModelProvider.notifier)
                              .createCollection(name);
                          if (!context.mounted) return;
                          if (ctx.mounted) {
                            Navigator.pop(ctx);
                            SnackbarUtils.showSuccess(
                              context,
                              'Collection "$name" created!',
                            );
                          }
                        }
                      },
                child: isCreating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    : const Text(
                        "Create",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final collectionState = ref.watch(collectionViewModelProvider);
    final productState = ref.watch(productViewModelProvider);
    final collections = collectionState.collections;
    final allProducts = productState.products;

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
          "Saved Items",
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _buildBody(collectionState, collections, allProducts),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateCollectionDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody(
    CollectionState state,
    List<CollectionEntity> collections,
    List<ProductEntity> allProducts,
  ) {
    if (state.status == CollectionStatus.loading && collections.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state.status == CollectionStatus.error && collections.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                state.errorMessage ?? "Failed to load saved items",
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  ref
                      .read(collectionViewModelProvider.notifier)
                      .getAllCollections();
                },
                icon: const Icon(Icons.refresh),
                label: const Text("Retry"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (collections.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) => Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primaryExtraLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite,
                    size: 44,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "No saved items yet",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Tap the ♡ icon on any product to save it here",
              style: TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showCreateCollectionDialog,
              icon: const Icon(Icons.add),
              label: const Text("Create Collection"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          ref.read(collectionViewModelProvider.notifier).getAllCollections(),
          ref.read(productViewModelProvider.notifier).getAllProducts(),
        ]);
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header with count
            Padding(
              padding: const EdgeInsets.only(bottom: 16, top: 4),
              child: Row(
                children: [
                  Text(
                    "My Collections",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryExtraLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "${collections.length} collection${collections.length == 1 ? '' : 's'}",
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// Collection grid
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.82,
                ),
                itemCount: collections.length,
                itemBuilder: (context, index) {
                  final collection = collections[index];
                  final products = _getProductsForCollection(
                    collection,
                    allProducts,
                  );
                  return _buildCollectionCard(collection, products, state);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollectionCard(
    CollectionEntity collection,
    List<ProductEntity> products,
    CollectionState state,
  ) {
    final productCount = products.length;
    final isLoading = state.isDeleting;
    final imageUrls = products
        .take(3)
        .map((p) => p.imageUrl)
        .where((url) => url != null && url.trim().isNotEmpty)
        .toList();

    return GestureDetector(
      onTap: () {
        _openCollectionProducts(collection, products);
      },
      onLongPress: () {
        _confirmDelete(collection.collectionId ?? '');
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Product image previews or heart placeholder
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: _buildPreviewSection(imageUrls, productCount),
              ),
            ),

            /// Collection name and info
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.favorite,
                    size: 14,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          collection.collectionName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "$productCount item${productCount == 1 ? '' : 's'}",
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isLoading)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: () => _confirmDelete(
                          collection.collectionId ?? ''),
                      child: const Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: AppColors.error,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewSection(List<String?> imageUrls, int productCount) {
    if (imageUrls.isEmpty) {
      return Container(
        color: AppColors.primaryExtraLight,
        child: Center(
          child: Icon(
            productCount > 0 ? Icons.favorite : Icons.favorite_border,
            size: 36,
            color: AppColors.primary.withValues(alpha: 0.3),
          ),
        ),
      );
    }

    if (imageUrls.length == 1) {
      return Stack(
        fit: StackFit.expand,
        children: [
          _networkImage(imageUrls[0]!),
          if (productCount > 3) _buildMoreBadge(productCount - 3),
        ],
      );
    }

    if (imageUrls.length == 2) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Row(
            children: [
              Expanded(child: _networkImage(imageUrls[0]!)),
              const VerticalDivider(width: 2, thickness: 2, color: Colors.white),
              Expanded(child: _networkImage(imageUrls[1]!)),
            ],
          ),
          if (productCount > 3) _buildMoreBadge(productCount - 3),
        ],
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(child: _networkImage(imageUrls[0]!)),
                  const VerticalDivider(width: 2, thickness: 2, color: Colors.white),
                  Expanded(child: _networkImage(imageUrls[1]!)),
                ],
              ),
            ),
            const Divider(height: 2, thickness: 2, color: Colors.white),
            Expanded(child: _networkImage(imageUrls[2]!)),
          ],
        ),
        if (productCount > 3) _buildMoreBadge(productCount - 3),
      ],
    );
  }

  Widget _buildMoreBadge(int remaining) {
    return Positioned(
      bottom: 6,
      right: 6,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 4,
            ),
          ],
        ),
        child: Text(
          "+$remaining",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _networkImage(String url) {
    final fullUrl = url.startsWith('http')
        ? url
        : '${ApiEndpoints.mediaServerUrl}${url.startsWith('/') ? '' : '/'}$url';
    return Image.network(
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
          child: const Icon(
            Icons.image_outlined,
            size: 24,
            color: AppColors.grey,
          ),
        );
      },
    );
  }

  void _openCollectionProducts(
    CollectionEntity collection,
    List<ProductEntity> products,
  ) {
    showCollectionProductsDialog(
      context,
      collection: collection,
      products: products,
    );
  }

  void _confirmDelete(String collectionId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Icons.delete_outline, color: AppColors.error, size: 20),
            const SizedBox(width: 8),
            Text(
              "Remove Collection",
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ],
        ),
        content: const Text(
          "This will remove all saved items in this collection.",
          style: TextStyle(color: AppColors.textSecondary),
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
              ref
                  .read(collectionViewModelProvider.notifier)
                  .deleteCollection(collectionId);
              Navigator.pop(ctx);
              SnackbarUtils.showError(
                context,
                "Collection removed",
              );
            },
            child: const Text(
              "Remove",
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<ProductEntity> _getProductsForCollection(
    CollectionEntity collection,
    List<ProductEntity> allProducts,
  ) {
    return allProducts
        .where((p) =>
            p.productId != null &&
            collection.productIds.contains(p.productId))
        .toList();
  }
}
