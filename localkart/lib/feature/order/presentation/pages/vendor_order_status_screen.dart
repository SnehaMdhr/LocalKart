import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/app/theme/app_colors.dart';
import 'package:localkart/core/api/api_endpoints.dart';
import 'package:localkart/feature/order/domain/entities/order_entity.dart';
import 'package:localkart/feature/order/presentation/view_model/order_view_model.dart';

class VendorOrderStatusScreen extends ConsumerStatefulWidget {
  final OrderEntity order;

  const VendorOrderStatusScreen({super.key, required this.order});

  @override
  ConsumerState<VendorOrderStatusScreen> createState() => _VendorOrderStatusScreenState();
}

class _VendorOrderStatusScreenState extends ConsumerState<VendorOrderStatusScreen> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderViewModelProvider);
    // Use the latest order from state if available, otherwise the initial one
    final order = orderState.currentOrder ?? widget.order;
    final mergedItems = _mergedItems(order);

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
          "Manage Order",
          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          /// Order ID & Date header
          _buildOrderHeader(order),
          const SizedBox(height: 20),

          /// Interactive Status Section
          _buildStatusManagement(order),
          const SizedBox(height: 24),

          /// Customer Info
          _sectionHeader("Customer & Delivery"),
          const SizedBox(height: 12),
          _buildCustomerCard(order),
          const SizedBox(height: 24),

          /// Items
          _sectionHeader("Items (${mergedItems.length})"),
          const SizedBox(height: 12),
          ...mergedItems.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildOrderItem(item),
          )),
          const SizedBox(height: 24),

          /// Payment Summary
          _sectionHeader("Payment Summary"),
          const SizedBox(height: 12),
          _buildPaymentSummary(order, mergedItems),
          const SizedBox(height: 30),

          /// Order ID
          Center(
            child: Text(
              "Order ID: ${order.orderId ?? 'N/A'}",
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildOrderHeader(OrderEntity order) {
    final shortId = (order.orderId ?? '').length >= 8
        ? (order.orderId ?? '').substring(0, 8).toUpperCase()
        : (order.orderId ?? '').toUpperCase();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryExtraLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.receipt_long, color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [                    Text(
                      order.orderNumber != null ? "Order #${order.orderNumber}" : "Order #$shortId",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimary),
                    ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(order.createdAt ?? ''),
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          _buildBadge(order.status),
        ],
      ),
    );
  }

  Widget _buildStatusManagement(OrderEntity order) {
    final allStatuses = ["Pending", "Accepted", "Preparing", "Out for Delivery", "Delivered"];
    final currentIndex = allStatuses.indexOf(order.status);
    final isTerminal = ["Delivered", "Rejected", "Cancelled"].contains(order.status);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.timeline, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text(
                "Order Progress",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const Spacer(),
              if (!isTerminal)
                Text(
                  order.status,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _statusColor(order.status),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          /// Interactive Timeline
          if (order.status == "Rejected")
            _buildRejectedTimeline()
          else if (order.status == "Cancelled")
            _buildCancelledTimeline()
          else
            ...List.generate(allStatuses.length, (index) {
              final status = allStatuses[index];
              final isCompleted = currentIndex >= index;
              final isCurrent = currentIndex == index;
              final isLast = index == allStatuses.length - 1;
              final canAdvance = isCurrent && !isTerminal;

              return _buildTimelineStep(
                status: status,
                isCompleted: isCompleted,
                isCurrent: isCurrent,
                isLast: isLast,
                canAdvance: canAdvance,
                onTap: canAdvance ? () => _advanceStatus(order, status) : null,
              );
            }),

          const SizedBox(height: 20),

          /// Action buttons at bottom
          if (!isTerminal) ...[
            const Divider(),
            const SizedBox(height: 16),
            if (order.status == "Pending")
              _buildPendingActions(order)
            else
              _buildAdvanceButton(order, allStatuses, currentIndex),
          ],
        ],
      ),
    );
  }

  Widget _buildRejectedTimeline() {
    return Column(
      children: [
        _buildTimelineStep(status: "Order Placed", isCompleted: true, isCurrent: false, isLast: false),
        _buildTimelineStep(status: "Order Rejected", isCompleted: false, isCurrent: true, isLast: true, showError: true),
      ],
    );
  }

  Widget _buildCancelledTimeline() {
    return Column(
      children: [
        _buildTimelineStep(status: "Order Placed", isCompleted: true, isCurrent: false, isLast: false),
        _buildTimelineStep(status: "Cancelled", isCompleted: false, isCurrent: true, isLast: true, showError: true),
      ],
    );
  }

  Widget _buildTimelineStep({
    required String status,
    required bool isCompleted,
    required bool isCurrent,
    required bool isLast,
    bool showError = false,
    bool canAdvance = false,
    VoidCallback? onTap,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Timeline indicator
          SizedBox(
            width: 32,
            child: Column(
              children: [
                GestureDetector(
                  onTap: canAdvance ? onTap : null,
                  child: Container(
                    width: isCurrent ? 26 : 20,
                    height: isCurrent ? 26 : 20,
                    decoration: BoxDecoration(
                      color: showError
                          ? AppColors.error
                          : isCompleted
                              ? AppColors.primary
                              : AppColors.border,
                      shape: BoxShape.circle,
                      border: isCurrent && !showError
                          ? Border.all(color: AppColors.primary, width: 4)
                          : null,
                      boxShadow: canAdvance
                          ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 6)]
                          : null,
                    ),
                    child: isCompleted && !isCurrent
                        ? const Icon(Icons.check, size: 12, color: Colors.white)
                        : showError
                            ? const Icon(Icons.close, size: 12, color: Colors.white)
                            : null,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isCompleted ? AppColors.primary : AppColors.border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          /// Status label
          Expanded(
            child: GestureDetector(
              onTap: canAdvance ? onTap : null,
              child: Container(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _timelineLabel(status),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                              color: showError
                                  ? AppColors.error
                                  : isCompleted
                                      ? AppColors.textPrimary
                                      : AppColors.textSecondary,
                            ),
                          ),
                        ),
                        if (canAdvance)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primaryExtraLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              "Tap to update →",
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (isCurrent && !showError)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          "Current status",
                          style: TextStyle(
                            color: AppColors.primary.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingActions(OrderEntity order) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isProcessing ? null : () => _rejectOrder(order),
            icon: const Icon(Icons.close, size: 18),
            label: const Text("Reject Order", style: TextStyle(fontSize: 14)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isProcessing ? null : () => _acceptOrder(order),
            icon: _isProcessing
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.check, size: 18),
            label: Text(_isProcessing ? "Processing..." : "Accept Order", style: const TextStyle(fontSize: 14)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdvanceButton(OrderEntity order, List<String> allStatuses, int currentIndex) {
    final nextIndex = currentIndex + 1;
    if (nextIndex >= allStatuses.length) return const SizedBox.shrink();

    final nextStatus = allStatuses[nextIndex];

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isProcessing ? null : () => _advanceStatus(order, allStatuses[currentIndex]),
        icon: _isProcessing
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.arrow_forward, size: 18),
        label: Text(
          _isProcessing ? "Updating..." : "Mark as $nextStatus",
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildCustomerCard(OrderEntity order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          /// Customer Info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryExtraLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person_outline, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Customer", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    const SizedBox(height: 2),
                    Text(
                      order.customerName ?? "Customer",
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.textPrimary),
                    ),
                    if (order.customerAddress != null && order.customerAddress!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              order.customerAddress!,
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (order.customerPhone != null && order.customerPhone!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.phone_outlined, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            order.customerPhone!,
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                    if (order.customerNote != null && order.customerNote!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.notes, size: 14, color: AppColors.warning),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                order.customerNote!,
                                style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontStyle: FontStyle.italic),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),

          /// Payment Method
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryExtraLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.payment, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Payment Method", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    const SizedBox(height: 2),
                    Text(order.paymentMethod, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.textPrimary)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: order.paymentStatus == "Paid"
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  order.paymentStatus,
                  style: TextStyle(
                    color: order.paymentStatus == "Paid" ? AppColors.success : AppColors.warning,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),

          /// Delivery Address
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryExtraLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Delivery Address", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    const SizedBox(height: 2),
                    Text(
                      order.deliveryAddress.isNotEmpty ? order.deliveryAddress : "No address provided",
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildOrderItem(OrderItemEntity item) {
    final imageUrl = item.imageUrl;
    final fullUrl = (imageUrl != null && imageUrl.trim().isNotEmpty)
        ? (imageUrl.startsWith('http') ? imageUrl : '${ApiEndpoints.mediaServerUrl}${imageUrl.startsWith('/') ? '' : '/'}$imageUrl')
        : null;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 64, height: 64,
              child: fullUrl != null
                  ? Image.network(fullUrl, fit: BoxFit.cover,
                      loadingBuilder: (c, child, p) => p == null ? child : Container(color: AppColors.inputFill, child: const Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)))),
                      errorBuilder: (c, e, s) => Container(color: AppColors.inputFill, child: const Icon(Icons.image_outlined, size: 28, color: AppColors.grey)))
                  : Container(color: AppColors.inputFill, child: const Icon(Icons.image_outlined, size: 28, color: AppColors.grey)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.productName ?? "Product", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text("Qty: ${item.quantity} × Rs. ${item.price ?? 0}", style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 4),
                Text("Rs. ${(item.price ?? 0) * item.quantity}", style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary(OrderEntity order, List<OrderItemEntity> mergedItems) {
    final subtotal = mergedItems.fold<int>(0, (sum, item) => sum + ((item.price ?? 0) * item.quantity));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          _summaryRow("Subtotal", "Rs.$subtotal"),
          const SizedBox(height: 10),
          _summaryRow("Delivery Fee", "FREE", valueColor: AppColors.primary),
          const Divider(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              Text("Rs. ${order.totalAmount}", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _statusBgColor(status),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(color: _statusColor(status), fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.textPrimary));
  }

  Widget _summaryRow(String title, String value, {Color valueColor = AppColors.textPrimary}) {
    return Row(
      children: [
        Text(title, style: const TextStyle(color: AppColors.textSecondary)),
        const Spacer(),
        Text(value, style: TextStyle(color: valueColor, fontWeight: FontWeight.bold)),
      ],
    );
  }

  String _timelineLabel(String status) {
    switch (status) {
      case "Pending": return "Order Placed";
      case "Accepted": return "Accepted by Shop";
      case "Preparing": return "Preparing Items";
      case "Out for Delivery": return "Out for Delivery";
      case "Delivered": return "Delivered";
      default: return status;
    }
  }

  Future<void> _acceptOrder(OrderEntity order) async {
    final orderId = order.orderId;
    if (orderId == null) return;

    setState(() => _isProcessing = true);
    await ref.read(orderViewModelProvider.notifier).acceptOrder(orderId);
    if (!mounted) return;
    setState(() => _isProcessing = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Order accepted! Move to Preparing when ready."),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _rejectOrder(OrderEntity order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Reject Order"),
        content: const Text("Are you sure you want to reject this order? This cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Reject", style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold))),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final orderId = order.orderId;
      if (orderId == null) return;

      setState(() => _isProcessing = true);
      await ref.read(orderViewModelProvider.notifier).rejectOrder(orderId);
      if (!mounted) return;
      setState(() => _isProcessing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Order rejected"),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _advanceStatus(OrderEntity order, String currentStatus) async {
    final allStatuses = ["Pending", "Accepted", "Preparing", "Out for Delivery", "Delivered"];
    final currentIndex = allStatuses.indexOf(currentStatus);
    if (currentIndex < 0 || currentIndex >= allStatuses.length - 1) return;

    final nextStatus = allStatuses[currentIndex + 1];
    final orderId = order.orderId;
    if (orderId == null) return;

    setState(() => _isProcessing = true);
    await ref.read(orderViewModelProvider.notifier).updateOrderStatus(
      orderId: orderId,
      status: nextStatus,
    );
    if (!mounted) return;
    setState(() => _isProcessing = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Status updated to $nextStatus"),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case "Pending": return AppColors.warning;
      case "Accepted": return AppColors.primary;
      case "Rejected": return AppColors.error;
      case "Preparing": return const Color(0xFFB8860B);
      case "Out for Delivery": return const Color(0xFF0288D1);
      case "Delivered": return AppColors.success;
      case "Cancelled": return AppColors.textSecondary;
      default: return AppColors.textSecondary;
    }
  }

  Color _statusBgColor(String status) {
    switch (status) {
      case "Pending": return AppColors.warning.withOpacity(0.15);
      case "Accepted": return const Color(0xFFE3F5E8);
      case "Rejected": return const Color(0xFFFFEEEE);
      case "Preparing": return const Color(0xFFFFF4D6);
      case "Out for Delivery": return const Color(0xFFE1F5FE);
      case "Delivered": return AppColors.success.withOpacity(0.15);
      case "Cancelled": return const Color(0xFFF3E5F5);
      default: return AppColors.inputFill;
    }
  }

  /// Merge items with the same productId and combine their quantities
  List<OrderItemEntity> _mergedItems(OrderEntity order) {
    final map = <String, OrderItemEntity>{};
    for (final item in order.items) {
      final key = item.productId;
      if (map.containsKey(key)) {
        final existing = map[key]!;
        map[key] = existing.copyWith(
          quantity: existing.quantity + item.quantity,
        );
      } else {
        map[key] = item;
      }
    }
    return map.values.toList();
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
      final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
      final amPm = date.hour >= 12 ? "PM" : "AM";
      final minute = date.minute.toString().padLeft(2, '0');
      return "${date.day} ${months[date.month - 1]}, ${date.year} \u2022 $hour:$minute $amPm";
    } catch (_) {
      return dateStr;
    }
  }
}
