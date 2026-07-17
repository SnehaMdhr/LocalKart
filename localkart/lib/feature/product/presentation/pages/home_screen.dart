import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/app/theme/app_colors.dart';
import 'package:localkart/core/services/storage/user_session_service.dart';
import 'package:localkart/core/widgets/bottom_navigation_bar_for_customer.dart';
import 'package:localkart/feature/order/domain/entities/order_entity.dart';
import 'package:localkart/feature/order/presentation/pages/order_detail_screen.dart';
import 'package:localkart/feature/order/presentation/view_model/order_view_model.dart';
import 'package:localkart/feature/product/presentation/pages/product_detail_screen.dart';
import 'package:localkart/feature/product/presentation/states/product_state.dart';
import 'package:localkart/feature/product/presentation/view_model/product_view_model.dart';
import 'package:localkart/feature/product/presentation/widgets/product_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(productViewModelProvider.notifier).getAllProducts();
      ref.read(orderViewModelProvider.notifier).getMyOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(userSessionServiceProvider);
    final userName = session.getCurrentUserName() ?? "User";
    final state = ref.watch(productViewModelProvider);
    final orderState = ref.watch(orderViewModelProvider);

    final inProgressStatuses = ["Pending", "Accepted", "Preparing", "Out for Delivery"];
    final activeOrders = (orderState.orders ?? [])
        .where((o) => inProgressStatuses.contains(o.status))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: _buildBody(state, userName, activeOrders),
    );
  }

  Widget _buildBody(ProductState state, String userName, List<OrderEntity> activeOrders) {
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
          
          const SizedBox(height: 18),

          /// Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
              color: AppColors.primaryExtraLight,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hello, $userName 👋",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  "Welcome back! Ready to shop fresh groceries today?",
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          /// Active Orders Section
          if (activeOrders.isNotEmpty) ...[            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10, height: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Active Orders",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...activeOrders.map((order) => GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OrderDetailScreen(order: order),
                  ),
                );
              },
              child: _buildActiveOrderCard(order),
            )),
            const SizedBox(height: 20),
          ],

          /// Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Quick Products",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BottomNavigationBarForCustomer(
                        initialTabIndex: 1,
                      ),
                    ),
                    (route) => false,
                  );
                },
                child: const Text(
                  "View All",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// Products Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.products.length > 4 ? 4 : state.products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.72,
            ),
            itemBuilder: (context, index) {
              final product = state.products[index];
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

  Widget _buildActiveOrderCard(OrderEntity order) {
    final itemCount = order.items.length;
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
        statusBgColor = AppColors.categoryVegetable;
        statusTextColor = AppColors.primary;
        break;
      case "Preparing":
        statusBgColor = AppColors.categoryDairy;
        statusTextColor = AppColors.preparing;
        break;
      case "Out for Delivery":
        statusBgColor = AppColors.deliveryInfoBg;
        statusTextColor = AppColors.deliveryInfo;
        break;
      default:
        statusBgColor = AppColors.inputFill;
        statusTextColor = AppColors.textSecondary;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          /// Order icon
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primaryExtraLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.receipt_long,
              color: AppColors.primary,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),

          /// Order info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "#$shortId",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(6),
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
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      "$itemCount item${itemCount != 1 ? 's' : ''}",
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      "Rs. ${order.totalAmount}",
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          /// Chevron
          const Icon(
            Icons.chevron_right,
            color: AppColors.textSecondary,
            size: 22,
          ),
        ],
      ),
    );
  }
}
