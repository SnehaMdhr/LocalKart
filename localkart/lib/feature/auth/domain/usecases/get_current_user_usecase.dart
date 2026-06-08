import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/core/error/failure.dart';
import 'package:localkart/core/usecases/app_usecase.dart';
import 'package:localkart/feature/auth/data/repositories/auth_repository.dart';
import 'package:localkart/feature/auth/domain/repositories/auth_repository.dart';


final getCurrentUserUsecaseProvider = Provider<GetCurrentUserUsecase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return GetCurrentUserUsecase(authRepository: authRepository);
});

class GetCurrentUserUsecase implements UsecaseWithoutParams {
  final IAuthRepository _authRepository;
  GetCurrentUserUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, dynamic>> call() {
    return _authRepository.getCurrentUser();
  }
}
