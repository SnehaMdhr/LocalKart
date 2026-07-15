import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/app/theme/app_colors.dart';
import 'package:localkart/feature/order/domain/entities/order_entity.dart';
import 'package:localkart/feature/order/presentation/pages/order_detail_screen.dart';
import 'package:localkart/feature/order/presentation/states/order_state.dart';
import 'package:localkart/feature/order/presentation/view_model/order_view_model.dart';

class MyOrdersScreen extends ConsumerStatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  ConsumerState<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends ConsumerState<MyOrdersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(orderViewModelProvider.notifier).getMyOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderViewModelProvider);
    final orders = orderState.orders ?? [];

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
          "My Orders",
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _buildBody(orderState, orders),
    );
  }

  Widget _buildBody(OrderState orderState, List<OrderEntity> orders) {
    if (orderState.status == OrderStatus.loading && orders.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (orderState.status == OrderStatus.error && orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
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
                  ref.read(orderViewModelProvider.notifier).getMyOrders();
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

    if (orders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_outlined, size: 72, color: AppColors.grey),
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
              "Your orders will appear here after you checkout",
              style: TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(orderViewModelProvider.notifier).getMyOrders(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _buildOrderCard(order),
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(OrderEntity order) {
    final itemCount = order.items.length;
    final displayId = order.orderNumber ??
        ((order.orderId ?? '').length >= 6
            ? (order.orderId ?? '').substring(0, 6).toUpperCase()
            : (order.orderId ?? '').toUpperCase());
    final dateStr = _formatDate(order.createdAt ?? '');

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OrderDetailScreen(order: order),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header row: Order # + Status badge
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _statusIconBg(order.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _statusIcon(order.status),
                      color: _statusColor(order.status),
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
                          dateStr,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(order.status),
                ],
              ),

              const SizedBox(height: 14),

              /// Order summary
              Row(
                children: [
                  /// Items count
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryExtraLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "$itemCount item${itemCount != 1 ? 's' : ''}",
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  /// Payment method
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.inputFill,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      order.paymentMethod,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const Spacer(),

                  /// Total amount
                  Text(
                    "Rs. ${order.totalAmount}",
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              /// Shop name (if available)
              if (order.shopName != null || order.vendorName != null) ...[
                Row(
                  children: [
                    const Icon(
                      Icons.store_outlined,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      order.shopName ?? order.vendorName ?? "Shop",
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ] else ...[
                const Row(
                  children: [
                    Spacer(),
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _statusBgColor(status),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: _statusColor(status),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _statusColor(String status) {
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

  Color _statusIconBg(String status) {
    switch (status) {
      case "Pending":
        return AppColors.warning.withValues(alpha: 0.15);
      case "Accepted":
      case "Preparing":
        return AppColors.primaryExtraLight;
      case "Out for Delivery":
        return const Color(0xFFE1F5FE);
      case "Delivered":
        return AppColors.success.withValues(alpha: 0.15);
      case "Cancelled":
      case "Rejected":
        return const Color(0xFFFFEEEE);
      default:
        return AppColors.inputFill;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case "Pending":
        return Icons.receipt_long;
      case "Accepted":
      case "Preparing":
        return Icons.inventory_2_outlined;
      case "Out for Delivery":
        return Icons.local_shipping_outlined;
      case "Delivered":
        return Icons.check_circle_outline;
      case "Cancelled":
      case "Rejected":
        return Icons.cancel_outlined;
      default:
        return Icons.receipt_long;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        "Jan", "Feb", "Mar", "Apr", "May", "Jun",
        "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
      ];
      final day = date.day;
      final month = months[date.month - 1];
      final year = date.year;
      final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
      final amPm = date.hour >= 12 ? "PM" : "AM";
      final minute = date.minute.toString().padLeft(2, '0');
      return "$day $month, $year • $hour:$minute $amPm";
    } catch (_) {
      return dateStr;
    }
  }
}
