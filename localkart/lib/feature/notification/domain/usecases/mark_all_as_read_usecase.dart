import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/core/error/failure.dart';
import 'package:localkart/core/usecases/app_usecase.dart';
import 'package:localkart/feature/notification/data/repositories/notification_repository.dart';
import 'package:localkart/feature/notification/domain/repositories/notification_repository.dart';

final markAllAsReadUsecaseProvider = Provider<MarkAllAsReadUsecase>((ref) {
  final repository = ref.read(notificationRepositoryProvider);
  return MarkAllAsReadUsecase(repository: repository);
});

class MarkAllAsReadUsecase implements UsecaseWithoutParams<void> {
  final INotificationRepository _repository;

  MarkAllAsReadUsecase({required INotificationRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, void>> call() {
    return _repository.markAllAsRead();
  }
}
