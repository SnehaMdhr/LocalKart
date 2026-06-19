import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/app/theme/app_colors.dart';
import 'package:localkart/feature/product/domain/entities/product_entity.dart';
import 'package:localkart/feature/product/presentation/pages/product_detail_screen.dart';
import 'package:localkart/feature/product/presentation/states/product_state.dart';
import 'package:localkart/feature/product/presentation/view_model/product_view_model.dart';
import 'package:localkart/feature/product/presentation/widgets/product_card.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  String? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  static const List<_CategoryData> _categories = [
    _CategoryData(
      icon: Icons.apple,
      label: 'Fruits',
      color: AppColors.categoryFruit,
    ),
    _CategoryData(
      icon: Icons.eco,
      label: 'Vegetables',
      color: AppColors.categoryVegetable,
    ),
    _CategoryData(
      icon: Icons.egg_alt,
      label: 'Dairy & Eggs',
      color: AppColors.categoryDairy,
    ),
    _CategoryData(
      icon: Icons.rice_bowl,
      label: 'Rice, Flour & Grains',
      color: AppColors.categoryGrains,
    ),
    _CategoryData(
      icon: Icons.grain,
      label: 'Pulses & Lentils',
      color: AppColors.categoryPulses,
    ),
    _CategoryData(
      icon: Icons.opacity,
      label: 'Cooking Oil & Ghee',
      color: AppColors.categoryOil,
    ),
    _CategoryData(
      icon: Icons.spa,
      label: 'Spices & Masala',
      color: AppColors.categorySpices,
    ),
    _CategoryData(
      icon: Icons.local_cafe,
      label: 'Tea, Coffee & Beverages',
      color: AppColors.categoryTea,
    ),
    _CategoryData(
      icon: Icons.cookie,
      label: 'Snacks & Biscuits',
      color: AppColors.categorySnacks,
    ),
    _CategoryData(
      icon: Icons.bakery_dining,
      label: 'Bakery & Bread',
      color: AppColors.categoryBakery,
    ),
    _CategoryData(
      icon: Icons.ac_unit,
      label: 'Frozen Foods',
      color: AppColors.categoryFrozen,
    ),
    _CategoryData(
      icon: Icons.soap,
      label: 'Personal Care',
      color: AppColors.categoryPersonal,
    ),
    _CategoryData(
      icon: Icons.cleaning_services,
      label: 'Household Essentials',
      color: AppColors.categoryHousehold,
    ),
    _CategoryData(
      icon: Icons.child_care,
      label: 'Baby Care',
      color: AppColors.categoryBaby,
    ),
  ];

  List<ProductEntity> _getFilteredProducts(List<ProductEntity> products) {
    var result = products;

    // Filter by selected category
    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      result = result
          .where(
            (p) =>
                p.categoryName.toLowerCase() ==
                _selectedCategory!.toLowerCase(),
          )
          .toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result
          .where(
            (p) =>
                p.productName.toLowerCase().contains(query) ||
                p.categoryName.toLowerCase().contains(query),
          )
          .toList();
    }

    return result;
  }

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(productViewModelProvider.notifier).getAllProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productViewModelProvider);
    final filteredProducts = _getFilteredProducts(state.products);

    if (state.status == ProductStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state.status == ProductStatus.error) {
      return Center(
        child: Text(
          state.errorMessage ?? "Something went wrong",
          style: const TextStyle(color: AppColors.error),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Search Bar
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                hintText: "Search for 'Organic Milk' or 'Dairy'",
                hintStyle: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
            ),
          ),

          const SizedBox(height: 24),

          /// Categories Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Categories",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedCategory = null;
                  });
                },
                child: Text(
                  _selectedCategory == null ? "" : "Clear Filter",
                  style: TextStyle(
                    color: _selectedCategory == null
                        ? Colors.transparent
                        : AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          /// Categories
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // "All" chip to reset filter
                _CategoryChip(
                  label: 'All',
                  isSelected: _selectedCategory == null,
                  onTap: () {
                    setState(() {
                      _selectedCategory = null;
                    });
                  },
                ),
                const SizedBox(width: 10),
                // Category items
                ..._categories.map(
                  (cat) => Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _CategoryItem(
                      icon: cat.icon,
                      label: cat.label,
                      color: cat.color,
                      isSelected:
                          _selectedCategory?.toLowerCase() ==
                          cat.label.toLowerCase(),
                      onTap: () {
                        setState(() {
                          _selectedCategory =
                              _selectedCategory?.toLowerCase() ==
                                  cat.label.toLowerCase()
                              ? null
                              : cat.label;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          /// Products Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedCategory ?? 'All Products',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              if (filteredProducts.isNotEmpty)
                Text(
                  '${filteredProducts.length} items',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          /// Product Grid
          if (filteredProducts.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Column(
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 64,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No products found',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredProducts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.72,
              ),
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                return ProductCard(
                  product: product,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(product: product),
                      ),
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}

/// Data class for category definitions
class _CategoryData {
  final IconData icon;
  final String label;
  final Color color;

  const _CategoryData({
    required this.icon,
    required this.label,
    required this.color,
  });
}

/// A small chip for the "All" option
class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

/// Category item with icon, label, and selection state
class _CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Column(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: isSelected ? AppColors.primary : color,
              child: Icon(
                icon,
                color: isSelected ? AppColors.white : AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
