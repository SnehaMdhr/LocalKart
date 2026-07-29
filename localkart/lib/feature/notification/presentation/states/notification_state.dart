import 'package:equatable/equatable.dart';
import '../../domain/entities/notification_entity.dart';

enum NotificationStatus { initial, loading, loaded, error }

class NotificationState extends Equatable {
  final NotificationStatus status;
  final List<NotificationEntity> notifications;
  final int unreadCount;
  final int currentPage;
  final bool hasMore;
  final String? errorMessage;

  const NotificationState({
    this.status = NotificationStatus.initial,
    this.notifications = const [],
    this.unreadCount = 0,
    this.currentPage = 1,
    this.hasMore = true,
    this.errorMessage,
  });

  NotificationState copyWith({
    NotificationStatus? status,
    List<NotificationEntity>? notifications,
    int? unreadCount,
    int? currentPage,
    bool? hasMore,
    String? errorMessage,
    bool clearNotifications = false,
  }) {
    return NotificationState(
      status: status ?? this.status,
      notifications:
          clearNotifications ? [] : (notifications ?? this.notifications),
      unreadCount: unreadCount ?? this.unreadCount,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    notifications,
    unreadCount,
    currentPage,
    hasMore,
    errorMessage,
  ];
}
