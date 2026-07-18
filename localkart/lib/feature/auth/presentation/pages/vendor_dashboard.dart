import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/app/theme/app_colors.dart';
import 'package:localkart/feature/order/domain/entities/order_entity.dart';
import 'package:localkart/feature/order/presentation/view_model/order_view_model.dart';
import 'package:localkart/feature/vendor_registeration/presentation/view_model/shop_view_model.dart';

class VendorDashboard extends ConsumerStatefulWidget {
  const VendorDashboard({super.key});

  @override
  ConsumerState<VendorDashboard> createState() => _VendorDashboardState();
}

class _VendorDashboardState extends ConsumerState<VendorDashboard> {
  int _previousPendingCount = -1;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(orderViewModelProvider.notifier).loadAllShopData();
      ref.read(shopViewModelProvider.notifier).getMyShop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderViewModelProvider);
    final shopState = ref.watch(shopViewModelProvider);
    final assignedOrders = orderState.orders ?? [];
    final pendingOrders = orderState.pendingOrders ?? [];
    final allOrders = [...assignedOrders, ...pendingOrders];
    final shopEntity = shopState.shopEntity;
    final stats = _calculateStats(assignedOrders, pendingOrders);
    final recentOrders = _getRecentOrders(allOrders);

    // Show SnackBar when a new order arrives via socket
    // Use pendingOrders nullability to detect when real data first loads
    final hasRealData = orderState.pendingOrders != null;

    if (_previousPendingCount == -1 && hasRealData) {
      // Initial load complete: capture baseline count, no SnackBar
      _previousPendingCount = pendingOrders.length;
    } else if (_previousPendingCount >= 0 &&
        pendingOrders.length > _previousPendingCount) {
      // Genuine new order arrived via socket
      final newOrder = pendingOrders.firstOrNull;
      if (newOrder != null) {
        final orderNum = newOrder.orderNumber ??
            (newOrder.orderId ?? '').substring(0, 6).toUpperCase();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _showNewOrderSnackbar(context, orderNum);
          }
        });
      }
      _previousPendingCount = pendingOrders.length;
    } else if (_previousPendingCount >= 0) {
      _previousPendingCount = pendingOrders.length;
    }

    return Scaffold(
      backgroundColor: AppColors.background,

      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            ref.read(orderViewModelProvider.notifier).loadAllShopData(),
            ref.read(shopViewModelProvider.notifier).getMyShop(),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Shop Name Greeting
              Text(
                shopEntity != null
                    ? "Namaste, ${shopEntity.shopName}"
                    : "Namaste, Vendor",
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 28),

              /// Stats Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.08,
                children: [
                  DashboardCard(
                    icon: Icons.pending_actions,
                    iconBg: AppColors.dashboardGreen,
                    iconColor: AppColors.primary,
                    title: "Pending",
                    value: "${stats.pending}",
                    badge: stats.pending > 0 ? "URGENT" : null,
                    badgeColor: AppColors.dashboardRed,
                    badgeText: AppColors.error,
                  ),
                  DashboardCard(
                    icon: Icons.local_shipping_outlined,
                    iconBg: AppColors.dashboardBlue,
                    iconColor: AppColors.primary,
                    title: "Out For Delivery",
                    value: "${stats.outForDelivery}",
                  ),
                  DashboardCard(
                    icon: Icons.inventory_2_outlined,
                    iconBg: AppColors.dashboardLightBlue,
                    iconColor: AppColors.deliveryInfo,
                    title: "Accepted",
                    value: "${stats.accepted}",
                  ),
                  DashboardCard(
                    icon: Icons.shopping_cart_checkout,
                    iconBg: AppColors.dashboardLightGreen,
                    iconColor: AppColors.primary,
                    title: "Delivered",
                    value: "${stats.delivered}",
                  ),
                ],
              ),

              const SizedBox(height: 28),

              /// Live Activity
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.divider),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.03),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            "Live Activity",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.logoutText,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "• RECENT ORDERS",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    if (recentOrders.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            "No recent orders",
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      )
                    else
                      ...List.generate(recentOrders.length, (index) {
                        final order = recentOrders[index];
                        final isLast = index == recentOrders.length - 1;
                        return _buildActivityTile(order, isLast);
                      }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNewOrderSnackbar(BuildContext context, String orderNumber) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.shopping_bag, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🛒 New Order Received',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    'Order #$orderNumber',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () {
            // Navigate to order screen already handled via bottom nav
          },
        ),
      ),
    );

    // Optional: Haptic feedback
    HapticFeedback.heavyImpact();
  }

  _Stats _calculateStats(List<OrderEntity> assignedOrders, List<OrderEntity> pendingOrders) {
    int pending = pendingOrders.length;
    int accepted = 0;
    int outForDelivery = 0;
    int delivered = 0;
    for (final order in assignedOrders) {
      switch (order.status) {
        case "Accepted": accepted++;
        case "Preparing": accepted++;
        case "Out for Delivery": outForDelivery++;
        case "Delivered": delivered++;
      }
    }
    return _Stats(pending: pending, accepted: accepted, outForDelivery: outForDelivery, delivered: delivered);
  }

  List<OrderEntity> _getRecentOrders(List<OrderEntity> orders) {
    final activeOrders = orders.where((o) => o.status != "Delivered").toList();
    final sorted = List<OrderEntity>.from(activeOrders)
      ..sort((a, b) => (b.createdAt ?? '').compareTo(a.createdAt ?? ''));
    return sorted.take(5).toList();
  }

  Widget _buildActivityTile(OrderEntity order, bool isLast) {
    IconData icon;
    Color iconColor;
    switch (order.status) {
      case "Pending": icon = Icons.shopping_bag_outlined; iconColor = Colors.orange;
      case "Accepted":
      case "Preparing": icon = Icons.inventory_2_outlined; iconColor = AppColors.primary;
      case "Out for Delivery": icon = Icons.local_shipping_outlined; iconColor = Colors.blue;
      case "Delivered": icon = Icons.check_circle_outline; iconColor = Colors.green;
      case "Cancelled":
      case "Rejected": icon = Icons.cancel_outlined; iconColor = Colors.red;
      default: icon = Icons.shopping_bag_outlined; iconColor = AppColors.textSecondary;
    }
    final itemCount = order.items.length;
    final shortId = (order.orderNumber ?? order.orderId ?? '');
    final displayId = shortId.length >= 8 ? shortId.substring(0, 8).toUpperCase() : shortId.toUpperCase();
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 24, backgroundColor: iconColor.withOpacity(.1), child: Icon(icon, color: iconColor, size: 22)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text("Order #$displayId", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const Spacer(),
                    Text(_formatTimeAgo(order.createdAt ?? ''), style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 4),
                Text("$itemCount item${itemCount != 1 ? 's' : ''} \u2022 Rs. ${order.totalAmount} \u2022 ${order.status}",
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 1) return "Just now";
      if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
      if (diff.inHours < 24) return "${diff.inHours}h ago";
      if (diff.inDays < 7) return "${diff.inDays}d ago";
      return "${diff.inDays ~/ 7}w ago";
    } catch (_) {
      return "";
    }
  }
}

class _Stats {
  final int pending;
  final int accepted;
  final int outForDelivery;
  final int delivered;
  const _Stats({required this.pending, required this.accepted, required this.outForDelivery, required this.delivered});
}

class DashboardCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String value;
  final String? badge;
  final Color? badgeColor;
  final Color? badgeText;

  const DashboardCard({
    super.key,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.value,
    this.badge,
    this.badgeColor,
    this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.03),
            blurRadius: 8,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const Spacer(),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badge!,
                    style: TextStyle(
                      color: badgeText,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),
          const Spacer(),
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: AppColors.textSecondary,
              letterSpacing: 1,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
