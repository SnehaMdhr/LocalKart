import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/app_usecase.dart';
import '../../data/repositories/auth_repository.dart';
import '../repositories/auth_repository.dart';

class ResetPasswordParams extends Equatable {
  final String email;
  final String otp;
  final String newPassword;
  final String confirmPassword;

  const ResetPasswordParams({
    required this.email,
    required this.otp,
    required this.newPassword,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [email, otp, newPassword, confirmPassword];
}

final resetPasswordUsecaseProvider = Provider<ResetPasswordUsecase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return ResetPasswordUsecase(authRepository: authRepository);
});

class ResetPasswordUsecase
    implements UseCaseWithParams<void, ResetPasswordParams> {
  final IAuthRepository _authRepository;
  ResetPasswordUsecase({required IAuthRepository authRepository})
      : _authRepository = authRepository;

  @override
  Future<Either<Failure, void>> call(ResetPasswordParams params) {
    return _authRepository.resetPassword(
      email: params.email,
      otp: params.otp,
      newPassword: params.newPassword,
      confirmPassword: params.confirmPassword,
    );
  }
}
