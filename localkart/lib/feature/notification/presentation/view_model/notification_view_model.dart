import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/feature/notification/domain/entities/notification_entity.dart';
import 'package:localkart/feature/notification/presentation/states/notification_state.dart';
import 'package:localkart/feature/notification/data/repositories/notification_repository.dart';
import 'package:localkart/feature/notification/domain/repositories/notification_repository.dart';

final notificationViewModelProvider =
    NotifierProvider<NotificationViewModel, NotificationState>(
  () => NotificationViewModel(),
);

class NotificationViewModel extends Notifier<NotificationState> {
  late final INotificationRepository _notificationRepository;

  @override
  NotificationState build() {
    _notificationRepository = ref.read(notificationRepositoryProvider);
    return const NotificationState();
  }

  /// Load notifications (initial or refresh)
  Future<void> getNotifications({bool refresh = false}) async {
    final page = refresh ? 1 : state.currentPage;
    if (!refresh && !state.hasMore) return;

    state = state.copyWith(status: NotificationStatus.loading);

    final result = await _notificationRepository.getNotifications(
      page: page,
      limit: 20,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: NotificationStatus.error,
          errorMessage: failure.message,
        );
      },
      (newNotifications) {
        final allNotifications = refresh
            ? newNotifications
            : [...state.notifications, ...newNotifications];

        state = state.copyWith(
          status: NotificationStatus.loaded,
          notifications: allNotifications,
          currentPage: refresh ? 2 : page + 1,
          hasMore: newNotifications.length >= 20,
          errorMessage: null,
        );
      },
    );
  }

  /// Refresh notifications
  Future<void> refreshNotifications() async {
    await getNotifications(refresh: true);
  }

  /// Fetch unread count
  Future<void> getUnreadCount() async {
    final result = await _notificationRepository.getUnreadCount();

    result.fold(
      (failure) {},
      (count) {
        state = state.copyWith(unreadCount: count);
      },
    );
  }

  /// Mark a single notification as read
  Future<void> markAsRead(String notificationId) async {
    final result = await _notificationRepository.markAsRead(notificationId);

    result.fold(
      (failure) {},
      (_) {
        final updatedNotifications = state.notifications.map((n) {
          if (n.notificationId == notificationId) {
            return n.copyWith(isRead: true);
          }
          return n;
        }).toList();

        final newUnreadCount =
            state.unreadCount > 0 ? state.unreadCount - 1 : 0;

        state = state.copyWith(
          notifications: updatedNotifications,
          unreadCount: newUnreadCount,
        );
      },
    );
  }

  /// Mark all as read
  Future<void> markAllAsRead() async {
    final result = await _notificationRepository.markAllAsRead();

    result.fold(
      (failure) {},
      (_) {
        final updatedNotifications = state.notifications.map((n) {
          return n.copyWith(isRead: true);
        }).toList();

        state = state.copyWith(
          notifications: updatedNotifications,
          unreadCount: 0,
        );
      },
    );
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    // Optimistic removal
    final wasUnread = state.notifications
        .firstWhere(
          (n) => n.notificationId == notificationId,
          orElse: () => const NotificationEntity(
            receiverId: '',
            receiverRole: '',
            title: '',
            message: '',
            type: '',
          ),
        )
        .isRead;

    final updatedNotifications = state.notifications
        .where((n) => n.notificationId != notificationId)
        .toList();

    state = state.copyWith(
      notifications: updatedNotifications,
      unreadCount:
          wasUnread && state.unreadCount > 0
              ? state.unreadCount - 1
              : state.unreadCount,
    );

    final result =
        await _notificationRepository.deleteNotification(notificationId);

    result.fold(
      (failure) {
        // Revert on failure — refetch
        getNotifications(refresh: true);
      },
      (_) {},
    );
  }

  /// Handle incoming real-time notification from Socket.IO
  void addNotificationFromSocket(NotificationEntity notification) {
    final updatedNotifications = [notification, ...state.notifications];
    state = state.copyWith(
      notifications: updatedNotifications,
      unreadCount: state.unreadCount + 1,
      status: NotificationStatus.loaded,
    );
  }

  /// Update unread count from socket badge event
  void updateUnreadCountFromSocket(int count) {
    state = state.copyWith(unreadCount: count);
  }
}
