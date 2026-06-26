import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/app/theme/app_colors.dart';
import 'package:localkart/core/api/api_endpoints.dart';
import 'package:localkart/feature/cart/presentation/view_model/cart_view_model.dart';
import 'package:localkart/feature/collection/domain/entities/collection_entity.dart';
import 'package:localkart/feature/collection/presentation/states/collection_state.dart';
import 'package:localkart/feature/collection/presentation/view_model/collection_view_model.dart';
import 'package:localkart/feature/product/domain/entities/product_entity.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final ProductEntity product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _quantity = 1;
  bool _isAddingToCart = false;

  @override
  void initState() {
    super.initState();
    // Preload collections so the picker opens fast
    Future.microtask(() {
      ref.read(collectionViewModelProvider.notifier).getAllCollections();
    });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() => _quantity--);
    }
  }

  void _incrementQuantity() {
    setState(() => _quantity++);
  }

  Future<void> _addToCart() async {
    final productId = widget.product.productId;
    if (productId == null || productId.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Product ID is not available"),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isAddingToCart = true);

    final success = await ref.read(cartViewModelProvider.notifier).addToCart(
          productId: productId,
          quantity: _quantity,
          productName: widget.product.productName,
          price: widget.product.price,
          imageUrl: widget.product.imageUrl,
        );

    setState(() => _isAddingToCart = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Added $_quantity ${widget.product.unit} of ${widget.product.productName} to cart",
            ),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
        // Reset quantity after successful add
        setState(() => _quantity = 1);
      } else {
        final cartState = ref.read(cartViewModelProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              cartState.errorMessage ?? "Failed to add to cart. Please try again.",
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  void _showCollectionPicker() {
    final productId = widget.product.productId;
    if (productId == null || productId.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Product ID is not available"),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _CollectionPickerSheet(productId: productId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartViewModelProvider);
    final collectionState = ref.watch(collectionViewModelProvider);
    final productId = widget.product.productId;

    // Check if this product is already in the cart
    final cartItem = cartState.cart.items.where(
      (item) => item.productId == productId,
    );
    final isInCart = cartItem.isNotEmpty;
    final cartQuantity = isInCart ? cartItem.first.quantity : 0;

    // Check if this product exists in any collection
    final isInAnyCollection =
        productId != null &&
        productId.trim().isNotEmpty &&
        collectionState.collections.any(
          (c) => c.productIds.contains(productId),
        );

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.product.productName,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showCollectionPicker,
            icon: Icon(
              isInAnyCollection ? Icons.bookmark : Icons.bookmark_border,
              color: isInAnyCollection ? AppColors.primary : AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),

      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
          ),
          child: Row(
            children: [
              /// Quantity Selector
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _decrementQuantity,
                      icon: const Icon(Icons.remove),
                    ),
                    Text(
                      "$_quantity",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: _incrementQuantity,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed:
                        _isAddingToCart ? null : _addToCart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isAddingToCart
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            isInCart
                                ? "Add ${_quantity > 0 ? "$_quantity more " : ""}to Cart"
                                : "Add to Cart",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Product Image
            SizedBox(
              height: 280,
              width: double.infinity,
              child: _buildProductImage(),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.product.productName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              widget.product.unit,
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryExtraLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Rs. ",
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(
                                text: "${widget.product.price}",
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  height: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  /// In-cart indicator
                  if (isInCart)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryExtraLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.shopping_cart,
                            size: 20,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "$cartQuantity item${cartQuantity == 1 ? '' : 's'} in cart",
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const Text(
                    "About the Product",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    widget.product.description?.isNotEmpty == true
                        ? widget.product.description!
                        : "No description available.",
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      height: 1.7,
                      fontSize: 15,
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

  Widget _buildProductImage() {
    final imageUrl = widget.product.imageUrl;

    if (imageUrl == null || imageUrl.trim().isEmpty) {
      return Container(
        color: AppColors.inputFill,
        child: const Center(
          child: Icon(Icons.image_outlined, size: 80, color: AppColors.grey),
        ),
      );
    }

    final fullUrl = imageUrl.startsWith('http')
        ? imageUrl
        : '${ApiEndpoints.mediaServerUrl}${imageUrl.startsWith('/') ? '' : '/'}$imageUrl';

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          fullUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: AppColors.inputFill,
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AppColors.inputFill,
              child: const Center(
                child: Icon(
                  Icons.broken_image_outlined,
                  size: 80,
                  color: AppColors.grey,
                ),
              ),
            );
          },
        ),

        /// Gradient overlay for better text readability
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  AppColors.background.withValues(alpha: 0.8),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Bottom sheet that shows all user collections and lets them pick one.
class _CollectionPickerSheet extends ConsumerStatefulWidget {
  final String productId;

  const _CollectionPickerSheet({required this.productId});

  @override
  ConsumerState<_CollectionPickerSheet> createState() =>
      _CollectionPickerSheetState();
}

class _CollectionPickerSheetState
    extends ConsumerState<_CollectionPickerSheet> {
  /// Track which collections are currently being added to.
  final Set<String> _addingCollectionIds = {};

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(collectionViewModelProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grey,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              /// Title
              const Text(
                "Save to Collection",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Choose a collection or create a new one",
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 16),

              /// Create new collection button
              _buildCreateNewTile(context, ref),

              const SizedBox(height: 12),

              /// Collections list
              Expanded(
                child: _buildCollectionsList(
                  context,
                  ref,
                  state,
                  scrollController,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCreateNewTile(BuildContext context, WidgetRef ref) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _showCreateDialog(context, ref),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primary, width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryExtraLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.add, color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              const Text(
                "Create new collection",
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCollectionsList(
    BuildContext context,
    WidgetRef ref,
    CollectionState state,
    ScrollController scrollController,
  ) {
    if (state.status == CollectionStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state.status == CollectionStatus.error) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40, color: AppColors.error),
            const SizedBox(height: 8),
            Text(
              state.errorMessage ?? "Failed to load collections",
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.error),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(collectionViewModelProvider.notifier)
                    .getAllCollections();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text("Retry", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (state.collections.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.collections_bookmark_outlined,
              size: 48,
              color: AppColors.grey,
            ),
            const SizedBox(height: 12),
            const Text(
              "No collections yet",
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 4),
            const Text(
              "Create one to get started",
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    // Check which collections already contain this product
    final productIdStr = widget.productId;
    final collections = state.collections;

    return ListView.separated(
      controller: scrollController,
      itemCount: collections.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final collection = collections[index];
        final alreadyContains = collection.productIds.contains(productIdStr);

        return _buildCollectionTile(context, ref, collection, alreadyContains);
      },
    );
  }

  Widget _buildCollectionTile(
    BuildContext context,
    WidgetRef ref,
    CollectionEntity collection,
    bool alreadyContains,
  ) {
    final collectionId = collection.collectionId ?? '';
    final productCount = collection.productIds.length;
    final isLoading = _addingCollectionIds.contains(collectionId);

    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: isLoading
            ? null
            : alreadyContains
            ? () => _confirmRemove(context, ref, collection)
            : () async {
                setState(() => _addingCollectionIds.add(collectionId));
                await ref
                    .read(collectionViewModelProvider.notifier)
                    .addProductToCollection(collectionId, widget.productId);
                setState(() => _addingCollectionIds.remove(collectionId));
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Added to \"${collection.collectionName}\"",
                      ),
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }
              },
        onDoubleTap: () => _showRenameDialog(context, ref, collection),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: alreadyContains
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: alreadyContains
                      ? AppColors.error.withValues(alpha: 0.1)
                      : AppColors.primaryExtraLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  alreadyContains
                      ? Icons.bookmark_remove_outlined
                      : Icons.folder_outlined,
                  color: alreadyContains ? AppColors.error : AppColors.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      collection.collectionName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "$productCount product${productCount == 1 ? '' : 's'}",
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (alreadyContains)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "Remove",
                    style: TextStyle(
                      color: AppColors.error,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else if (isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmRemove(
    BuildContext context,
    WidgetRef ref,
    CollectionEntity collection,
  ) {
    showDialog(
      context: context,
      builder: (ctx) {
        var isRemoving = false;
        return StatefulBuilder(
          builder: (_, setDialogState) => AlertDialog(
            backgroundColor: AppColors.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              isRemoving ? "Removing..." : "Remove Product",
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            content: Text(
              isRemoving
                  ? 'Removing from "${collection.collectionName}"...'
                  : 'Remove from "${collection.collectionName}"?',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              if (!isRemoving)
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              TextButton(
                onPressed: isRemoving
                    ? null
                    : () async {
                        setDialogState(() => isRemoving = true);
                        await ref
                            .read(collectionViewModelProvider.notifier)
                            .removeProductFromCollection(
                              collection.collectionId ?? '',
                              widget.productId,
                            );
                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Removed from "${collection.collectionName}"',
                              ),
                              backgroundColor: AppColors.error,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        }
                      },
                child: isRemoving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.error,
                        ),
                      )
                    : const Text(
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
      },
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        var isCreating = false;
        return StatefulBuilder(
          builder: (_, setDialogState) => AlertDialog(
            backgroundColor: AppColors.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              isCreating ? "Creating..." : "New Collection",
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            content: TextField(
              controller: controller,
              autofocus: true,
              enabled: !isCreating,
              decoration: InputDecoration(
                hintText: "Collection name",
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.inputFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            actions: [
              if (!isCreating)
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: AppColors.textSecondary),
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
                          if (ctx.mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Collection "$name" created!'),
                                backgroundColor: AppColors.primary,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
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

  void _showRenameDialog(
    BuildContext context,
    WidgetRef ref,
    CollectionEntity collection,
  ) {
    final controller = TextEditingController(text: collection.collectionName);
    showDialog(
      context: context,
      builder: (ctx) {
        var isUpdating = false;
        return StatefulBuilder(
          builder: (_, setDialogState) => AlertDialog(
            backgroundColor: AppColors.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              isUpdating ? "Updating..." : "Rename Collection",
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            content: TextField(
              controller: controller,
              autofocus: true,
              enabled: !isUpdating,
              decoration: InputDecoration(
                hintText: "New collection name",
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.inputFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            actions: [
              if (!isUpdating)
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              TextButton(
                onPressed: isUpdating
                    ? null
                    : () async {
                        final newName = controller.text.trim();
                        if (newName.isNotEmpty &&
                            newName != collection.collectionName) {
                          setDialogState(() => isUpdating = true);
                          await ref
                              .read(collectionViewModelProvider.notifier)
                              .updateCollectionName(
                                collection.collectionId ?? '',
                                newName,
                              );
                          if (ctx.mounted) {
                            Navigator.pop(ctx);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Renamed to "$newName"'),
                                backgroundColor: AppColors.primary,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          }
                        } else if (newName == collection.collectionName) {
                          Navigator.pop(ctx);
                        }
                      },
                child: isUpdating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    : const Text(
                        "Rename",
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
}
