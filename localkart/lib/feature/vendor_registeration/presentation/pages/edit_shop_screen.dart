import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/app/theme/app_colors.dart';
import 'package:localkart/core/utils/snackbar_utils.dart';
import 'package:localkart/core/widgets/custom_button.dart';
import 'package:localkart/core/widgets/custom_text_field.dart';
import 'package:localkart/feature/vendor_registeration/presentation/states/shop_state.dart';
import 'package:localkart/feature/vendor_registeration/presentation/view_model/shop_view_model.dart';

class EditShopScreen extends ConsumerStatefulWidget {
  const EditShopScreen({super.key});

  @override
  ConsumerState<EditShopScreen> createState() => _EditShopScreenState();
}

class _EditShopScreenState extends ConsumerState<EditShopScreen> {
  final _formKey = GlobalKey<FormState>();

  final shopNameController = TextEditingController();
  final addressController = TextEditingController();
  final descriptionController = TextEditingController();

  final Set<String> selectedCategories = {};

  final List<String> allCategories = [
    "Fruits & Vegetables",
    "Dairy & Eggs",
    "Meat & Seafood",
    "Bakery",
    "Beverages",
    "Snacks & Confectionery",
    "Frozen Foods",
    "Organic & Health Foods",
    "Pantry Staples",
    "Baby & Pet",
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _populateFields();
    });
  }

  void _populateFields() {
    final shop = ref.read(shopViewModelProvider).shopEntity;
    if (shop != null) {
      shopNameController.text = shop.shopName;
      addressController.text = shop.address;
      descriptionController.text = shop.description;
      selectedCategories.addAll(shop.categories);
      setState(() {});
    }
  }

  Future<void> _handleUpdate() async {
    if (_formKey.currentState!.validate()) {
      if (selectedCategories.isEmpty) {
        SnackbarUtils.showError(
          context,
          "Please select at least one category",
        );
        return;
      }
      await ref.read(shopViewModelProvider.notifier).updateShop(
            shopName: shopNameController.text.trim(),
            address: addressController.text.trim(),
            description: descriptionController.text.trim(),
            categories: selectedCategories.toList(),
          );
    }
  }

  @override
  void dispose() {
    shopNameController.dispose();
    addressController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shopState = ref.watch(shopViewModelProvider);
    final isLoading = shopState.status == ShopStatus.loading;

    ref.listen<ShopState>(shopViewModelProvider, (previous, next) {
      if (next.status == ShopStatus.error) {
        SnackbarUtils.showError(
          context,
          next.errorMessage ?? "Failed to update shop",
          duration: const Duration(seconds: 1),
        );
      } else if (next.status == ShopStatus.loaded &&
          previous?.status == ShopStatus.loading) {
        SnackbarUtils.showSuccess(
          context,
          "Shop updated successfully",
          duration: const Duration(seconds: 1),
        );
        Navigator.pop(context);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text(
          "Edit Shop",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Shop Info Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          "Update Your Shop",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Center(
                        child: Text(
                          "Modify your shop details below",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      /// Store Name
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Store Name",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: shopNameController,
                        hint: "e.g. Fresh Garden Organics",
                        prefixIcon: Icons.storefront_outlined,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Store name is required";
                          }
                          if (value.trim().length < 3) {
                            return "Store name must be at least 3 characters";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      /// Categories
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Business Categories",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.inputFill,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: allCategories.map((category) {
                                final isSelected = selectedCategories.contains(category);
                                return FilterChip(
                                  label: Text(
                                    category,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : AppColors.textPrimary,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                      fontSize: 13,
                                    ),
                                  ),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        selectedCategories.add(category);
                                      } else {
                                        selectedCategories.remove(category);
                                      }
                                    });
                                  },
                                  selectedColor: AppColors.primary,
                                  checkmarkColor: Colors.white,
                                  backgroundColor: Colors.transparent,
                                  side: BorderSide(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textSecondary.withValues(alpha: 0.3),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                );
                              }).toList(),
                            ),
                            if (selectedCategories.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                "${selectedCategories.length} selected",
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      /// Address
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Full Address",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: addressController,
                        hint: "Enter your complete shop address",
                        prefixIcon: Icons.location_on_outlined,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Address is required";
                          }
                          if (value.trim().length < 3) {
                            return "Address must be at least 3 characters";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      /// Description
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Description",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: descriptionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.inputFill,
                          hintText: "Description",
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(bottom: 45),
                            child: Icon(Icons.description_outlined),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Description is required";
                          }
                          if (value.trim().length < 10) {
                            return "Description must be at least 10 characters";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 40),

                      /// Update Button
                      CustomButton(
                        text: "Update Shop",
                        isLoading: isLoading,
                        onPressed: _handleUpdate,
                        borderRadius: 18,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
