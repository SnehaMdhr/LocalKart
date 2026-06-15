import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/app_usecase.dart';
import '../../data/repositories/auth_repository.dart';
import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUsecaseParams extends Equatable {

  final String name;
  final String email;
  final String? phone;
  final String? username;
  final String password;
  final String confirmPassword;

  RegisterUsecaseParams({
    required this.name,
    required this.email,
    this.phone,
    required this.username,
    required this.password,
    required this.confirmPassword,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [name,email,phone,username,password,confirmPassword];
}
final registerUsecaseProvider = Provider<RegisterUsecase>((ref){
  final authRepository = ref.read(authRepositoryProvider);
  return RegisterUsecase(authRepository: authRepository);
});
class RegisterUsecase implements UseCaseWithParams<bool, RegisterUsecaseParams> {
  final IAuthRepository _authRepository;
  RegisterUsecase({required IAuthRepository authRepository})
      : _authRepository =authRepository;

  @override
  Future<Either<Failure, bool>> call(RegisterUsecaseParams params) {
    final entity = AuthEntity(
        name: params.name,
        email: params.email,
        phone: params.phone,
        username: params.username,
        password: params.password,
        confirmPassword: params.confirmPassword);
    return _authRepository.register(entity);
  }
}