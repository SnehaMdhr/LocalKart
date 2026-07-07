import 'package:flutter/material.dart';
import 'package:localkart/app/theme/app_colors.dart';
import 'package:localkart/core/api/api_endpoints.dart';
import 'package:localkart/feature/order/domain/entities/order_entity.dart';

class OrderDetailScreen extends StatelessWidget {
  final OrderEntity order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
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
          "Order Details",
          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          _buildStatusSection(order),
          const SizedBox(height: 24),
          _buildInfoHeader(order),
          const SizedBox(height: 24),
          _sectionHeader("Items (${mergedItems.length})"),
          const SizedBox(height: 12),
          ...mergedItems.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildOrderItem(item),
          )),
          const SizedBox(height: 24),
          _sectionHeader("Payment Summary"),
          const SizedBox(height: 12),
          _buildPaymentSummary(order, mergedItems),
          const SizedBox(height: 24),
          /// Vendor / Shop Info (shown when order is accepted)
          if (order.shopName != null || order.vendorName != null) ...[
            _sectionHeader("Vendor / Shop"),
            const SizedBox(height: 12),
            _buildVendorCard(order),
            const SizedBox(height: 24),
          ],

          _sectionHeader("Delivery Address"),
          const SizedBox(height: 12),
          _buildAddressCard(order),
          const SizedBox(height: 30),
          Center(
            child: Text(
              "Order ID: ${order.orderId ?? 'N/A'}",
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildStatusSection(OrderEntity order) {
    final statuses = ["Pending", "Accepted", "Preparing", "Out for Delivery", "Delivered"];
    final currentIndex = statuses.indexOf(order.status);

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
              Text(order.status, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _statusColor(order.status))),
              const Spacer(),
              _buildStatusBadge(order.status),
            ],
          ),
          const SizedBox(height: 18),
          ...List.generate(statuses.length, (index) {
            final status = statuses[index];
            final isCompleted = currentIndex >= index;
            final isLast = index == statuses.length - 1;

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    child: Column(
                      children: [
                        Container(
                          width: 12, height: 12,
                          decoration: BoxDecoration(
                            color: isCompleted ? AppColors.primary : AppColors.border,
                            shape: BoxShape.circle,
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
                  const SizedBox(width: 12),
                  Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: isCompleted ? AppColors.textPrimary : AppColors.textSecondary,
                        fontWeight: isCompleted ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildInfoHeader(OrderEntity order) {
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
            decoration: BoxDecoration(color: AppColors.primaryExtraLight, borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.receipt_long, color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Order #${_shortId(order.orderId ?? '')}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text(_formatDate(order.createdAt ?? ''), style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: order.paymentStatus == "Paid" ? AppColors.success.withOpacity(0.1) : AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(order.paymentStatus, style: TextStyle(color: order.paymentStatus == "Paid" ? AppColors.success : AppColors.warning, fontSize: 12, fontWeight: FontWeight.w600)),
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            width: 72, height: 72,
            child: fullUrl != null
                ? Image.network(fullUrl, fit: BoxFit.cover,
                    loadingBuilder: (c, child, p) => p == null ? child : Container(color: AppColors.inputFill, child: const Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)))),
                    errorBuilder: (c, e, s) => Container(color: AppColors.inputFill, child: const Icon(Icons.image_outlined, size: 32, color: AppColors.grey)))
                : Container(color: AppColors.inputFill, child: const Icon(Icons.image_outlined, size: 32, color: AppColors.grey)),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.productName ?? "Product", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text("Qty: ${item.quantity}", style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 6),
              Text("Rs. ${item.price ?? 0}", style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
        ),
        Text("Rs. ${(item.price ?? 0) * item.quantity}", style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 15)),
      ],
    );
  }

  Widget _buildPaymentSummary(OrderEntity order, List<OrderItemEntity> mergedItems) {
    final subtotal = mergedItems.fold<int>(0, (sum, item) => sum + ((item.price ?? 0) * item.quantity));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.divider)),
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
          const SizedBox(height: 16),
          Row(
            children: [
              const Text("Payment: ", style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.primaryExtraLight, borderRadius: BorderRadius.circular(8)),
                child: Text(order.paymentMethod, style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildVendorCard(OrderEntity order) {
    return Container(
      padding: const EdgeInsets.all(16),
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
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.store_outlined, color: AppColors.success, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.shopName ?? order.vendorName ?? "Shop",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Accepted your order",
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          if (order.shopAddress != null && order.shopAddress!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.shopAddress!,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          if (order.shopPhone != null && order.shopPhone!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const Icon(Icons.phone_outlined, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    order.shopPhone!,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(OrderEntity order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.divider)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.primaryExtraLight, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.deliveryAddress.isNotEmpty ? order.deliveryAddress : "No address provided",
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, height: 1.5),
                ),
                if (order.latitude != null && order.longitude != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      "${order.latitude!.toStringAsFixed(6)}, ${order.longitude!.toStringAsFixed(6)}",
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                    ),
                  ),
              ],
            ),
          ),
        ],
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

  Widget _buildStatusBadge(String status) {
    Color bgColor, textColor;
    switch (status) {
      case "Pending": bgColor = AppColors.warning.withOpacity(0.15); textColor = AppColors.warning; break;
      case "Accepted": bgColor = const Color(0xFFE3F5E8); textColor = AppColors.primary; break;
      case "Rejected": bgColor = const Color(0xFFFFEEEE); textColor = AppColors.error; break;
      case "Preparing": bgColor = const Color(0xFFFFF4D6); textColor = Color(0xFFB8860B); break;
      case "Out for Delivery": bgColor = const Color(0xFFE1F5FE); textColor = Color(0xFF0288D1); break;
      case "Delivered": bgColor = AppColors.success.withOpacity(0.15); textColor = AppColors.success; break;
      case "Cancelled": bgColor = const Color(0xFFF3E5F5); textColor = AppColors.textSecondary; break;
      default: bgColor = AppColors.inputFill; textColor = AppColors.textSecondary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
      child: Text(status, style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w600)),
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

  String _shortId(String id) {
    if (id.length >= 8) return id.substring(0, 8).toUpperCase();
    return id.toUpperCase();
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
