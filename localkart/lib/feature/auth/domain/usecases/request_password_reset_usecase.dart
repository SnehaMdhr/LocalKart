import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/app_usecase.dart';
import '../../data/repositories/auth_repository.dart';
import '../repositories/auth_repository.dart';

class RequestPasswordResetParams extends Equatable {
  final String email;

  const RequestPasswordResetParams({required this.email});

  @override
  List<Object?> get props => [email];
}

final requestPasswordResetUsecaseProvider =
    Provider<RequestPasswordResetUsecase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return RequestPasswordResetUsecase(authRepository: authRepository);
});

class RequestPasswordResetUsecase
    implements UseCaseWithParams<void, RequestPasswordResetParams> {
  final IAuthRepository _authRepository;
  RequestPasswordResetUsecase({required IAuthRepository authRepository})
      : _authRepository = authRepository;

  @override
  Future<Either<Failure, void>> call(RequestPasswordResetParams params) {
    return _authRepository.requestPasswordResetOtp(params.email);
  }
}
