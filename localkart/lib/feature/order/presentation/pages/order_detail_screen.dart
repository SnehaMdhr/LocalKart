import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/app/theme/app_colors.dart';
import 'package:localkart/core/api/api_endpoints.dart';
import 'package:localkart/feature/order/domain/entities/order_entity.dart';
import 'package:localkart/feature/order/presentation/view_model/order_view_model.dart';
import 'package:localkart/feature/rating/presentation/states/rating_state.dart';
import 'package:localkart/feature/rating/presentation/view_model/rating_view_model.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  final OrderEntity order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  bool _shouldShowEtd(String status) {
    const etdStatuses = ["Out for Delivery", "Delivered"];
    return etdStatuses.contains(status);
  }

  @override
  void initState() {
    super.initState();
    // Fetch vendor ratings if the order has been accepted by a vendor
    final shopId = widget.order.shopId;
    if (shopId != null && shopId.isNotEmpty) {
      Future.microtask(() {
        ref.read(ratingViewModelProvider.notifier).getVendorRatings(shopId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderViewModelProvider);
    final etdInfo = orderState.etdInfo;

    // Reactively fetch ETD when order status changes to Out for Delivery or Delivered
    ref.listen(orderViewModelProvider, (previous, next) {
      final prevStatus = previous?.currentOrder?.status ?? widget.order.status;
      final currStatus = next.currentOrder?.status ?? widget.order.status;
      if (_shouldShowEtd(currStatus) && !_shouldShowEtd(prevStatus)) {
        final orderId = next.currentOrder?.orderId ?? widget.order.orderId;
        if (orderId != null) {
          ref.read(orderViewModelProvider.notifier).getOrderEtd(orderId);
        }
      }
    });

    // Also fetch on initial build if order is already in applicable status
    if (etdInfo == null) {
      final orderId = widget.order.orderId;
      final currStatus = orderState.currentOrder?.status ?? widget.order.status;
      if (orderId != null && _shouldShowEtd(currStatus)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(orderViewModelProvider.notifier).getOrderEtd(orderId);
        });
      }
    }
    final mergedItems = _mergedItems(widget.order);

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
          _buildStatusSection(widget.order, etdInfo),
          const SizedBox(height: 24),
          _buildInfoHeader(widget.order),
          const SizedBox(height: 24),
          _sectionHeader("Items (${mergedItems.length})"),
          const SizedBox(height: 12),
          ...mergedItems.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              padding: const EdgeInsets.all(14),
              child: _buildOrderItem(item),
            ),
          )),
          const SizedBox(height: 24),
          _sectionHeader("Payment Summary"),
          const SizedBox(height: 12),
          _buildPaymentSummary(widget.order, mergedItems),
          const SizedBox(height: 24),
          /// Vendor / Shop Info (shown when order is accepted)
          if (widget.order.shopName != null || widget.order.vendorName != null) ...[
            _sectionHeader("Vendor / Shop"),
            const SizedBox(height: 12),
            _buildVendorCard(widget.order),
            const SizedBox(height: 24),
          ],

          Center(
            child: Text(
              "Order ID: ${widget.order.orderId ?? 'N/A'}",
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildStatusSection(OrderEntity order, Map<String, dynamic>? etdInfo) {
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

          /// ETD section — shown when Out for Delivery or Delivered
          if (_shouldShowEtd(order.status) && etdInfo != null && etdInfo['available'] == true) ...[
            const SizedBox(height: 20),
            _buildEtdCard(etdInfo, order.status),
          ] else if (_shouldShowEtd(order.status) && etdInfo == null) ...[
            const SizedBox(height: 20),
            _buildEtdLoading(),
          ] else if (_shouldShowEtd(order.status) && etdInfo != null && etdInfo['available'] == false) ...[
            const SizedBox(height: 20),
            _buildEtdUnavailable(etdInfo),
          ],
        ],
      ),
    );
  }

  Widget _buildEtdCard(Map<String, dynamic> etdInfo, String orderStatus) {
    final distance = etdInfo['distance'];
    final estimatedMinutes = etdInfo['estimatedMinutes'];
    final distanceKm = distance is double ? distance.toStringAsFixed(1) : '${distance ?? '--'}';
    final minutes = estimatedMinutes is int ? estimatedMinutes : '${estimatedMinutes ?? '--'}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.deliveryInfoBg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.deliveryInfo.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.deliveryInfo.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.delivery_dining, color: AppColors.deliveryInfo, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  orderStatus == "Delivered"
                      ? "Delivered successfully"
                      : "Rider is on the way",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.deliveryInfo,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRect(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        if (orderStatus == "Out for Delivery") ...[
                          const Icon(Icons.timer_outlined, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            "ETA: $minutes mins",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        const Icon(Icons.map_outlined, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          "$distanceKm km away",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEtdUnavailable(Map<String, dynamic> etdInfo) {
    final reason = etdInfo['reason'] as String? ?? 'Location data not available';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: AppColors.warning, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "ETD Unavailable",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.preparing,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reason,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEtdLoading() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 28, height: 28,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
          ),
          SizedBox(width: 14),
          Text(
            "Calculating estimated delivery...",
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
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
                Text("Order #${_shortId(order.orderId ?? '')} Payment Status", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text(_formatDate(order.createdAt ?? ''), style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: order.paymentStatus == "Paid" ? AppColors.success.withValues(alpha: 0.1) : AppColors.warning.withValues(alpha: 0.1),
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
    // Inline rating stats
    final ratingState = ref.watch(ratingViewModelProvider);
    final stats = ratingState.vendorStats;

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.store_outlined, color: AppColors.success, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Shop name
                    Text(
                      order.shopName ?? order.vendorName ?? "Shop",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    /// Rating row — small, below the shop name
                    if (stats != null && stats.totalRatings > 0)
                      _buildCompactRatingRow(stats)
                    else if (stats != null && stats.totalRatings == 0)
                      Row(
                        children: [
                          const Icon(Icons.star_outline_rounded, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          const Text(
                            'No ratings yet',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                          ),
                        ],
                      )
                    else
                      const SizedBox.shrink(),
                    const SizedBox(height: 2),
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

  /// Compact inline rating row — small stars with average number
  Widget _buildCompactRatingRow(VendorRatingStats stats) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          stats.averageRating.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: 2),
        ...List.generate(5, (index) {
          final starNumber = index + 1;
          final filled = starNumber <= stats.averageRating.round();
          return Padding(
            padding: const EdgeInsets.only(right: 1),
            child: Icon(
              filled ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 14,
              color: filled ? AppColors.warning : AppColors.grey.withValues(alpha: 0.3),
            ),
          );
        }),
        const SizedBox(width: 4),
        Text(
          '(${stats.totalRatings})',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
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
      case "Pending": bgColor = AppColors.warning.withValues(alpha: 0.15); textColor = AppColors.warning; break;
      case "Accepted": bgColor = AppColors.categoryVegetable; textColor = AppColors.primary; break;
      case "Rejected": bgColor = AppColors.logoutBackground; textColor = AppColors.error; break;
      case "Preparing": bgColor = AppColors.categoryDairy; textColor = AppColors.preparing; break;
      case "Out for Delivery": bgColor = AppColors.deliveryInfoBg; textColor = AppColors.deliveryInfo; break;
      case "Delivered": bgColor = AppColors.success.withValues(alpha: 0.15); textColor = AppColors.success; break;
      case "Cancelled": bgColor = AppColors.categoryPersonal; textColor = AppColors.textSecondary; break;
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
      case "Preparing": return AppColors.preparing;
      case "Out for Delivery": return AppColors.deliveryInfo;
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
