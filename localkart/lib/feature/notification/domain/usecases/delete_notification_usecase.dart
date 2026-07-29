import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/core/error/failure.dart';
import 'package:localkart/core/usecases/app_usecase.dart';
import 'package:localkart/feature/notification/data/repositories/notification_repository.dart';
import 'package:localkart/feature/notification/domain/repositories/notification_repository.dart';

final deleteNotificationUsecaseProvider =
    Provider<DeleteNotificationUsecase>((ref) {
  final repository = ref.read(notificationRepositoryProvider);
  return DeleteNotificationUsecase(repository: repository);
});

class DeleteNotificationParams extends Equatable {
  final String notificationId;

  const DeleteNotificationParams({required this.notificationId});

  @override
  List<Object?> get props => [notificationId];
}

class DeleteNotificationUsecase
    implements UseCaseWithParams<void, DeleteNotificationParams> {
  final INotificationRepository _repository;

  DeleteNotificationUsecase({required INotificationRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, void>> call(DeleteNotificationParams params) {
    return _repository.deleteNotification(params.notificationId);
  }
}
