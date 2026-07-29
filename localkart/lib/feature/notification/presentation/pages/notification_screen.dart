import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/app/theme/app_colors.dart';
import 'package:localkart/feature/auth/presentation/view_model/auth_view_model.dart';
import 'package:localkart/feature/notification/domain/entities/notification_entity.dart';
import 'package:localkart/feature/notification/presentation/states/notification_state.dart';
import 'package:localkart/feature/notification/presentation/view_model/notification_view_model.dart';
import 'package:localkart/feature/order/presentation/pages/order_detail_screen.dart';
import 'package:localkart/feature/order/presentation/pages/vendor_order_status_screen.dart';
import 'package:localkart/feature/order/presentation/view_model/order_view_model.dart';
import 'package:localkart/feature/rating/presentation/view_model/rating_view_model.dart';
import 'package:localkart/feature/rating/presentation/widgets/rating_dialog.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() =>
      _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  final ScrollController _scrollController = ScrollController();
  // Track which order IDs have been rated locally
  final Set<String> _ratedOrderIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationViewModelProvider.notifier).refreshNotifications();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(notificationViewModelProvider.notifier).getNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationViewModelProvider);
    final authState = ref.watch(authViewModelProvider);
    final userRole = authState.authEntity?.role ?? 'Customer';

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
          'Notifications',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          if (state.unreadCount > 0)
            TextButton.icon(
              onPressed: () {
                ref
                    .read(notificationViewModelProvider.notifier)
                    .markAllAsRead();
              },
              icon: const Icon(Icons.done_all, size: 18, color: AppColors.primary),
              label: const Text(
                'Mark all read',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(state, userRole),
    );
  }

  Widget _buildBody(NotificationState state, String userRole) {
    switch (state.status) {
      case NotificationStatus.initial:
      case NotificationStatus.loading:
        if (state.notifications.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        return _buildList(state, userRole);
      case NotificationStatus.loaded:
        if (state.notifications.isEmpty) {
          return _buildEmptyState();
        }
        return _buildList(state, userRole);
      case NotificationStatus.error:
        if (state.notifications.isEmpty) {
          return _buildErrorState(state.errorMessage);
        }
        return _buildList(state, userRole);
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primaryExtraLight,
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              size: 48,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No notifications yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'When you get notifications, they\'ll appear here',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              ref
                  .read(notificationViewModelProvider.notifier)
                  .refreshNotifications();
            },
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String? errorMessage) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.logoutBackground,
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              size: 40,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            errorMessage ?? 'Something went wrong',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              ref
                  .read(notificationViewModelProvider.notifier)
                  .refreshNotifications();
            },
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(NotificationState state, String userRole) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .read(notificationViewModelProvider.notifier)
            .refreshNotifications();
      },
      color: AppColors.primary,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
        itemCount: state.notifications.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.notifications.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ),
            );
          }

          final notification = state.notifications[index];
          return _NotificationCard(
            notification: notification,
            userRole: userRole,
            onTap: () {
              if (!notification.isRead) {
                if (notification.notificationId != null) {
                  ref
                      .read(notificationViewModelProvider.notifier)
                      .markAsRead(notification.notificationId!);
                }
              }
              _handleNotificationTap(notification, userRole);
            },
            onDismiss: () {
              if (notification.notificationId != null) {
                ref
                    .read(notificationViewModelProvider.notifier)
                    .deleteNotification(notification.notificationId!);
              }
            },
            isRated: notification.orderId != null && _ratedOrderIds.contains(notification.orderId),
            onTrackOrder: () => _navigateToOrderDetail(notification, userRole),
            onRateOrder: () => _showRatingDialog(notification),
            onViewOrder: () => _navigateToOrderDetail(notification, userRole),
            onViewRating: () => _showRatingDialog(notification),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  Navigation helpers
  // ═══════════════════════════════════════════════════════════════════════════

  void _handleNotificationTap(NotificationEntity notification, String userRole) {
    if (notification.orderId == null) return;
    _navigateToOrderDetail(notification, userRole);
  }

  Future<void> _navigateToOrderDetail(
    NotificationEntity notification,
    String userRole,
  ) async {
    final orderId = notification.orderId;
    if (orderId == null || orderId.isEmpty) return;

    // Fetch the full order by ID
    await ref.read(orderViewModelProvider.notifier).getOrderById(orderId);

    if (!mounted) return;

    final currentOrder = ref.read(orderViewModelProvider).currentOrder;
    if (currentOrder == null) return;

    if (userRole == 'Shopkeeper') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VendorOrderStatusScreen(order: currentOrder),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OrderDetailScreen(order: currentOrder),
        ),
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  Show the rating dialog (bottom sheet) for delivered orders
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _showRatingDialog(NotificationEntity notification) async {
    final orderId = notification.orderId;
    if (orderId == null || orderId.isEmpty) return;

    // Fetch the full order by ID
    await ref.read(orderViewModelProvider.notifier).getOrderById(orderId);

    if (!mounted) return;

    final currentOrder = ref.read(orderViewModelProvider).currentOrder;
    if (currentOrder == null) return;

    // Check if already rated
    await ref.read(ratingViewModelProvider.notifier).getOrderRating(orderId);
    if (!mounted) return;

    final ratingState = ref.read(ratingViewModelProvider);
    final existingRating = ratingState.currentRating;

    // Show the modern bottom sheet dialog
    final result = await showRatingDialog(
      context,
      order: currentOrder,
      existingRating: existingRating,
    );

    // If rating was submitted/updated, mark this order as rated
    if (result == true && mounted) {
      setState(() {
        _ratedOrderIds.add(orderId);
      });
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  Notification Card Widget with Action Buttons
// ═══════════════════════════════════════════════════════════════════════════════

class _NotificationCard extends StatelessWidget {
  final NotificationEntity notification;
  final String userRole;
  final VoidCallback onTap;
  final VoidCallback onDismiss;
  final bool isRated;
  final VoidCallback? onTrackOrder;
  final VoidCallback? onRateOrder;
  final VoidCallback? onViewOrder;
  final VoidCallback? onViewRating;

  const _NotificationCard({
    required this.notification,
    required this.userRole,
    required this.onTap,
    required this.onDismiss,
    this.isRated = false,
    this.onTrackOrder,
    this.onRateOrder,
    this.onViewOrder,
    this.onViewRating,
  });

  @override
  Widget build(BuildContext context) {
    final iconInfo = _getIconInfo(notification.type);
    final timeAgo = _getTimeAgo(notification.createdAt);
    final isVendorNewOrder =
        userRole == 'Shopkeeper' && notification.type == 'ORDER_PLACED';

    return Dismissible(
      key: Key(notification.notificationId ?? notification.hashCode.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.white, size: 28),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: notification.isRead ? AppColors.white : AppColors.primaryExtraLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: notification.isRead
                  ? AppColors.divider
                  : AppColors.primary.withValues(alpha: 0.15),
              width: notification.isRead ? 1 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Icon with colored circle ──
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: iconInfo.color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(iconInfo.icon, color: iconInfo.color, size: 24),
                  ),
                  const SizedBox(width: 14),

                  // ── Content ──
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: TextStyle(
                                  fontWeight: notification.isRead
                                      ? FontWeight.w500
                                      : FontWeight.bold,
                                  fontSize: 15,
                                  color: AppColors.textPrimary,
                                  height: 1.3,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              timeAgo,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          notification.message,
                          style: TextStyle(
                            fontSize: 13,
                            color: notification.isRead
                                ? AppColors.textSecondary
                                : AppColors.textPrimary,
                            height: 1.4,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // ── Unread dot indicator ──
                        if (!notification.isRead)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'New',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              // ═══════════════════════════════════════════════════════════
              //  Action Buttons based on notification type + role
              // ═══════════════════════════════════════════════════════════
              if (notification.type == 'ORDER_ACCEPTED' &&
                  userRole == 'Customer' &&
                  onTrackOrder != null)
                _buildActionButtonRow([
                  _ActionButton(
                    label: 'Track Order',
                    icon: Icons.navigation_rounded,
                    color: AppColors.primary,
                    onTap: onTrackOrder!,
                  ),
                ])
              else if (notification.type == 'DELIVERED' &&
                  userRole == 'Customer' &&
                  onRateOrder != null)
                _buildActionButtonRow([
                  if (isRated && onViewRating != null)
                    _ActionButton(
                      label: 'View Rating',
                      icon: Icons.star_rounded,
                      color: AppColors.success,
                      onTap: onViewRating!,
                    )
                  else if (!isRated)
                    _ActionButton(
                      label: 'Rate Experience',
                      icon: Icons.star_rounded,
                      color: AppColors.warning,
                      onTap: onRateOrder!,
                    )
                ])
              else if (isVendorNewOrder && onViewOrder != null)
                _buildActionButtonRow([
                  _ActionButton(
                    label: 'View & Manage',
                    icon: Icons.shopping_bag_rounded,
                    color: AppColors.primary,
                    onTap: onViewOrder!,
                  ),
                ])
              else if (notification.type == 'ORDER_CANCELLED' &&
                  userRole == 'Customer' &&
                  onViewOrder != null)
                _buildActionButtonRow([
                  _ActionButton(
                    label: 'View Order',
                    icon: Icons.arrow_forward,
                    color: AppColors.textSecondary,
                    onTap: onViewOrder!,
                  ),
                ])
              else if (notification.type == 'SHOP_APPROVED' ||
                  notification.type == 'SHOP_REJECTED')
                _buildActionButtonRow([
                  _ActionButton(
                    label: 'View Shop',
                    icon: Icons.store_rounded,
                    color: notification.type == 'SHOP_APPROVED'
                        ? AppColors.success
                        : AppColors.error,
                    onTap: onTap,
                  ),
                ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtonRow(List<_ActionButton> buttons) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: buttons.map((btn) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: buttons.indexOf(btn) > 0 ? 8 : 0,
              ),
              child: OutlinedButton.icon(
                onPressed: btn.onTap,
                icon: Icon(btn.icon, size: 16),
                label: Text(
                  btn.label,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: btn.color,
                  side: BorderSide(color: btn.color.withValues(alpha: 0.4)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 12,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  _IconInfo _getIconInfo(String type) {
    switch (type) {
      case 'ORDER_PLACED':
        return _IconInfo(Icons.receipt_long_rounded, AppColors.warning);
      case 'ORDER_ACCEPTED':
        return _IconInfo(Icons.check_circle_outline_rounded, AppColors.success);
      case 'ORDER_REJECTED':
        return _IconInfo(Icons.cancel_outlined, AppColors.error);
      case 'ORDER_PREPARING':
        return _IconInfo(Icons.shopping_basket_rounded, AppColors.preparing);
      case 'OUT_FOR_DELIVERY':
        return _IconInfo(Icons.delivery_dining_rounded, AppColors.deliveryInfo);
      case 'DELIVERED':
        return _IconInfo(Icons.inventory_2_rounded, AppColors.grey);
      case 'ORDER_CANCELLED':
        return _IconInfo(Icons.cancel_schedule_send_rounded, AppColors.error);
      case 'SHOP_APPROVED':
        return _IconInfo(Icons.store_rounded, AppColors.success);
      case 'SHOP_REJECTED':
        return _IconInfo(Icons.store_rounded, AppColors.error);
      case 'SYSTEM':
        return _IconInfo(Icons.info_outline_rounded, AppColors.textSecondary);
      default:
        return _IconInfo(Icons.notifications_outlined, AppColors.textSecondary);
    }
  }

  String _getTimeAgo(String? createdAt) {
    if (createdAt == null) return '';
    try {
      final date = DateTime.parse(createdAt);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
      return '${(diff.inDays / 30).floor()}mo ago';
    } catch (_) {
      return '';
    }
  }
}

class _ActionButton {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class _IconInfo {
  final IconData icon;
  final Color color;

  const _IconInfo(this.icon, this.color);
}
