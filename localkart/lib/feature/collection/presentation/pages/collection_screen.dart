import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/app/theme/app_colors.dart';
import 'package:localkart/feature/collection/presentation/states/collection_state.dart';
import 'package:localkart/feature/collection/presentation/view_model/collection_view_model.dart';
import 'package:localkart/feature/collection/domain/entities/collection_entity.dart';
import 'package:localkart/feature/collection/presentation/pages/collection_products_sheet.dart';
import 'package:localkart/feature/product/presentation/view_model/product_view_model.dart';

class CollectionScreen extends ConsumerStatefulWidget {
  const CollectionScreen({super.key});

  @override
  ConsumerState<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends ConsumerState<CollectionScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(collectionViewModelProvider.notifier).getAllCollections();
    });
    Future.microtask(() {
      ref.read(productViewModelProvider.notifier).getAllProducts();
    });
  }

  void _showCreateCollectionDialog() {
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
            content: isCreating
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
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
                      hintText: "Collection name",
                      hintStyle: const TextStyle(
                          color: AppColors.textSecondary),
                      filled: true,
                      fillColor: AppColors.inputFill,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(
                        color: AppColors.textPrimary),
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
                          if (ctx.mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Collection "$name" created!',
                                ),
                                backgroundColor: AppColors.primary,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(10),
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(collectionViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          "My Collections",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showCreateCollectionDialog,
            icon: const Icon(Icons.add_circle_outline,
                color: AppColors.primary),
          ),
        ],
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(CollectionState state) {
    if (state.status == CollectionStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state.status == CollectionStatus.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              state.errorMessage ?? "Something went wrong",
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.error),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(collectionViewModelProvider.notifier)
                    .getAllCollections();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text("Retry",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (state.collections.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.collections_bookmark_outlined,
                size: 64, color: AppColors.grey),
            const SizedBox(height: 16),
            const Text(
              "No collections yet",
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Tap + to create your first collection",
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.collections.length,
      itemBuilder: (context, index) {
        final collection = state.collections[index];
        return _buildCollectionCard(collection, state);
      },
    );
  }

  Widget _buildCollectionCard(
    CollectionEntity collection,
    CollectionState state,
  ) {
    final isLoading = state.isDeleting;
    final productCount = collection.productIds.length;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.divider),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primaryExtraLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.folder_outlined,
            color: AppColors.primary,
          ),
        ),
        title: Text(
          collection.collectionName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          "$productCount product${productCount == 1 ? '' : 's'}",
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        trailing: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              )
            : IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: AppColors.error),
                onPressed: () {
                  _confirmDelete(collection.collectionId ?? "");
                },
              ),
        onTap: () {
          final allProducts = ref.read(productViewModelProvider).products;
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
      ),
    );
  }

  void _confirmDelete(String collectionId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Delete Collection",
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          "Are you sure you want to delete this collection?",
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
            },
            child: const Text(
              "Delete",
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
}
