import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/app/theme/app_colors.dart';
import 'package:localkart/core/api/api_endpoints.dart';
import 'package:localkart/feature/order/domain/entities/order_entity.dart';
import 'package:localkart/feature/order/presentation/pages/vendor_order_status_screen.dart';
import 'package:localkart/feature/order/presentation/states/order_state.dart';
import 'package:localkart/feature/order/presentation/view_model/order_view_model.dart';

class VendorOrderScreen extends ConsumerStatefulWidget {
  static void navigateToStatus(BuildContext context, OrderEntity order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VendorOrderStatusScreen(order: order),
      ),
    );
  }
  const VendorOrderScreen({super.key});

  @override
  ConsumerState<VendorOrderScreen> createState() => _VendorOrderScreenState();
}

class _VendorOrderScreenState extends ConsumerState<VendorOrderScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(orderViewModelProvider.notifier).loadAllShopData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderViewModelProvider);
    final pendingOrders = orderState.pendingOrders ?? [];
    final activeOrders = (orderState.orders ?? [])
        .where((o) => ["Accepted", "Preparing", "Out for Delivery"]
            .contains(o.status))
        .toList();
    final completedOrders = (orderState.orders ?? [])
        .where((o) => ["Delivered", "Rejected", "Cancelled"]
            .contains(o.status))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: _buildBody(
        orderState,
        pendingOrders,
        activeOrders,
        completedOrders,
      ),
    );
  }

  Widget _buildBody(
    OrderState orderState,
    List<OrderEntity> pending,
    List<OrderEntity> active,
    List<OrderEntity> completed,
  ) {
    if (orderState.status == OrderStatus.loading &&
        pending.isEmpty &&
        (orderState.orders ?? []).isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (orderState.status == OrderStatus.error &&
        pending.isEmpty &&
        (orderState.orders ?? []).isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              orderState.errorMessage ?? "Failed to load orders",
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
                    .read(orderViewModelProvider.notifier)
                    .loadAllShopData();
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
      );
    }

    if (pending.isEmpty && active.isEmpty && completed.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 72, color: AppColors.grey),
            SizedBox(height: 16),
            Text(
              "No orders yet",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 6),
            Text(
              "Orders from customers will appear here",
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(orderViewModelProvider.notifier).loadAllShopData(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          /// Stats summary
          _buildStatsRow(pending.length, active.length, completed.length),
          const SizedBox(height: 20),

          /// Pending Orders (from /shop/pending)
          if (pending.isNotEmpty) ...[
            _sectionHeader("New Orders", pending.length, AppColors.warning),
            const SizedBox(height: 12),
            ...pending.map((order) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _buildOrderCard(order, isPending: true),
                )),
            const SizedBox(height: 8),
          ],

          /// Active Orders (from /shop/orders - Accepted, Preparing, Out for Delivery)
          if (active.isNotEmpty) ...[
            _sectionHeader("In Progress", active.length, AppColors.primary),
            const SizedBox(height: 12),
            ...active.map((order) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _buildOrderCard(order, isPending: false),
                )),
            const SizedBox(height: 8),
          ],

          /// Completed Orders
          if (completed.isNotEmpty) ...[
            _sectionHeader("Completed", completed.length, AppColors.success),
            const SizedBox(height: 12),
            ...completed.map((order) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _buildCompactOrderCard(order),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsRow(int pending, int active, int completed) {
    return Row(
      children: [
        _statChip(
          "New",
          pending,
          AppColors.warning,
          AppColors.warning.withValues(alpha: 0.15),
        ),
        const SizedBox(width: 10),
        _statChip(
          "Active",
          active,
          AppColors.primary,
          AppColors.primaryExtraLight,
        ),
        const SizedBox(width: 10),
        _statChip(
          "Done",
          completed,
          AppColors.success,
          AppColors.success.withValues(alpha: 0.15),
        ),
      ],
    );
  }

  Widget _statChip(
    String label,
    int count,
    Color textColor,
    Color bgColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          "$title ($count)",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(OrderEntity order, {required bool isPending}) {
    final itemCount = order.items.length;
    final displayId = order.orderNumber ??
        ((order.orderId ?? '').length >= 6
            ? (order.orderId ?? '').substring(0, 6).toUpperCase()
            : (order.orderId ?? '').toUpperCase());

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isPending
              ? AppColors.warning.withValues(alpha: 0.3)
              : AppColors.divider,
          width: isPending ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isPending
                        ? AppColors.warning.withValues(alpha: 0.15)
                        : AppColors.primaryExtraLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.receipt_long,
                    color: isPending ? AppColors.warning : AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Order #$displayId",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "$itemCount item${itemCount != 1 ? 's' : ''}",
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _statusBgColor(order.status),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    order.status,
                    style: TextStyle(
                      color: _statusTextColor(order.status),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// Items preview
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount:
                    order.items.length > 3 ? 3 : order.items.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final item = order.items[index];
                  final imageUrl = item.imageUrl;
                  final fullUrl =
                      (imageUrl != null && imageUrl.trim().isNotEmpty)
                          ? (imageUrl.startsWith('http')
                              ? imageUrl
                              : '${ApiEndpoints.mediaServerUrl}${imageUrl.startsWith('/') ? '' : '/'}$imageUrl')
                          : null;
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 36,
                      height: 36,
                      child: fullUrl != null
                          ? Image.network(fullUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => Container(
                                    color: AppColors.inputFill,
                                    child: const Icon(
                                      Icons.image_outlined,
                                      size: 16,
                                      color: AppColors.grey,
                                    ),
                                  ))
                          : Container(
                              color: AppColors.inputFill,
                              child: const Icon(
                                Icons.image_outlined,
                                size: 16,
                                color: AppColors.grey,
                              ),
                            ),
                    ),
                  );
                },
              ),
            ),
          ),

          /// Total
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Row(
              children: [
                const Text(
                  "Total: ",
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                Text(
                  "Rs. ${order.totalAmount}",
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const Spacer(),
                Text(
                  order.paymentMethod,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          /// Action buttons
          if (isPending)
            _buildPendingActions(order)
          else if (order.status == "Accepted")
            _buildStatusActions(order, ["Preparing", "Rejected"])
          else if (order.status == "Preparing")
            _buildStatusActions(order, ["Out for Delivery"])
          else if (order.status == "Out for Delivery")
            _buildStatusActions(order, ["Delivered"])
          else
            _buildViewButton(order),
        ],
      ),
    );
  }

  Widget _buildPendingActions(OrderEntity order) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Row(
        children: [
          /// View Details
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _viewOrder(order),
              icon: const Icon(Icons.visibility, size: 18),
              label: const Text("View", style: TextStyle(fontSize: 13)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                side: const BorderSide(color: AppColors.divider),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 10),

          /// Reject
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _confirmReject(order),
              icon: const Icon(Icons.close, size: 18),
              label: const Text("Reject", style: TextStyle(fontSize: 13)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 10),

          /// Accept
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _acceptOrder(order),
              icon: const Icon(Icons.check, size: 18),
              label: const Text("Accept", style: TextStyle(fontSize: 13)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusActions(
    OrderEntity order,
    List<String> nextStatuses,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Row(
        children: [
          /// View Details
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _viewOrder(order),
              icon: const Icon(Icons.visibility, size: 18),
              label: const Text("View", style: TextStyle(fontSize: 13)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                side: const BorderSide(color: AppColors.divider),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 10),

          ...nextStatuses.map((status) {
            if (status == "Rejected") {
              return Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _confirmReject(order),
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text("Reject",
                      style: TextStyle(fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              );
            }
            return Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _updateStatus(order, status),
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: Text(status,
                    style: const TextStyle(fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildViewButton(OrderEntity order) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => _viewOrder(order),
          icon: const Icon(Icons.visibility, size: 18),
          label: const Text("View Details",
              style: TextStyle(fontSize: 13)),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            side: const BorderSide(color: AppColors.divider),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactOrderCard(OrderEntity order) {
    final displayId = order.orderNumber ??
        ((order.orderId ?? '').length >= 6
            ? (order.orderId ?? '').substring(0, 6).toUpperCase()
            : (order.orderId ?? '').toUpperCase());

    return GestureDetector(
      onTap: () => _viewOrder(order),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
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
              child: const Icon(
                Icons.receipt_long,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "#$displayId",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Rs. ${order.totalAmount}",
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: _statusBgColor(order.status),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                order.status,
                style: TextStyle(
                  color: _statusTextColor(order.status),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _viewOrder(OrderEntity order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VendorOrderStatusScreen(order: order),
      ),
    );
  }

  Future<void> _acceptOrder(OrderEntity order) async {
    final orderId = order.orderId;
    if (orderId == null) return;

    await ref
        .read(orderViewModelProvider.notifier)
        .acceptOrder(orderId);
    if (!mounted) return;

    // Refresh both pending and active lists
    ref.read(orderViewModelProvider.notifier).loadAllShopData();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Order accepted successfully"),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _confirmReject(OrderEntity order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text("Reject Order",
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
            )),
        content: const Text(
          "Are you sure you want to reject this order? This action cannot be undone.",
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel",
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Reject",
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                )),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final orderId = order.orderId;
      if (orderId == null) return;
      await ref
          .read(orderViewModelProvider.notifier)
          .rejectOrder(orderId);
      if (!mounted) return;

      // Refresh to remove rejected order from list
      ref.read(orderViewModelProvider.notifier).loadAllShopData();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Order rejected"),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _updateStatus(
    OrderEntity order,
    String newStatus,
  ) async {
    final orderId = order.orderId;
    if (orderId == null) return;

    await ref
        .read(orderViewModelProvider.notifier)
        .updateOrderStatus(orderId: orderId, status: newStatus);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Order status updated to $newStatus"),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Color _statusBgColor(String status) {
    switch (status) {
      case "Pending":
        return AppColors.warning.withValues(alpha: 0.15);
      case "Accepted":
        return const Color(0xFFE3F5E8);
      case "Rejected":
        return const Color(0xFFFFEEEE);
      case "Preparing":
        return const Color(0xFFFFF4D6);
      case "Out for Delivery":
        return const Color(0xFFE1F5FE);
      case "Delivered":
        return AppColors.success.withValues(alpha: 0.15);
      case "Cancelled":
        return const Color(0xFFF3E5F5);
      default:
        return AppColors.inputFill;
    }
  }

  Color _statusTextColor(String status) {
    switch (status) {
      case "Pending":
        return AppColors.warning;
      case "Accepted":
        return AppColors.primary;
      case "Rejected":
        return AppColors.error;
      case "Preparing":
        return const Color(0xFFB8860B);
      case "Out for Delivery":
        return const Color(0xFF0288D1);
      case "Delivered":
        return AppColors.success;
      case "Cancelled":
        return AppColors.textSecondary;
      default:
        return AppColors.textSecondary;
    }
  }
}
