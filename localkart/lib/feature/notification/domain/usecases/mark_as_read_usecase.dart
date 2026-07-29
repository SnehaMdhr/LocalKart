import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/core/error/failure.dart';
import 'package:localkart/core/usecases/app_usecase.dart';
import 'package:localkart/feature/notification/data/repositories/notification_repository.dart';
import 'package:localkart/feature/notification/domain/repositories/notification_repository.dart';

final markAsReadUsecaseProvider = Provider<MarkAsReadUsecase>((ref) {
  final repository = ref.read(notificationRepositoryProvider);
  return MarkAsReadUsecase(repository: repository);
});

class MarkAsReadParams extends Equatable {
  final String notificationId;

  const MarkAsReadParams({required this.notificationId});

  @override
  List<Object?> get props => [notificationId];
}

class MarkAsReadUsecase
    implements UseCaseWithParams<void, MarkAsReadParams> {
  final INotificationRepository _repository;

  MarkAsReadUsecase({required INotificationRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, void>> call(MarkAsReadParams params) {
    return _repository.markAsRead(params.notificationId);
  }
}
