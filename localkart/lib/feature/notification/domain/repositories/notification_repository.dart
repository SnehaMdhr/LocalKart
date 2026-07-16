import 'package:dartz/dartz.dart';
import 'package:localkart/core/error/failure.dart';
import 'package:localkart/feature/notification/domain/entities/notification_entity.dart';

abstract interface class INotificationRepository {
  Future<Either<Failure, List<NotificationEntity>>> getNotifications({
    int page = 1,
    int limit = 20,
  });

  Future<Either<Failure, int>> getUnreadCount();

  Future<Either<Failure, void>> markAsRead(String notificationId);

  Future<Either<Failure, void>> markAllAsRead();

  Future<Either<Failure, void>> deleteNotification(String notificationId);
}
