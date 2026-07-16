import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/core/error/failure.dart';
import 'package:localkart/core/usecases/app_usecase.dart';
import 'package:localkart/feature/notification/data/repositories/notification_repository.dart';
import 'package:localkart/feature/notification/domain/entities/notification_entity.dart';
import 'package:localkart/feature/notification/domain/repositories/notification_repository.dart';

final getNotificationsUsecaseProvider = Provider<GetNotificationsUsecase>((ref) {
  final repository = ref.read(notificationRepositoryProvider);
  return GetNotificationsUsecase(repository: repository);
});

class GetNotificationsUsecase
    implements UsecaseWithoutParams<List<NotificationEntity>> {
  final INotificationRepository _repository;

  GetNotificationsUsecase({required INotificationRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, List<NotificationEntity>>> call() {
    return _repository.getNotifications();
  }
}
