import 'package:dartz/dartz.dart';
import 'package:localkart/core/error/failure.dart';
import 'package:localkart/feature/auth/domain/entities/auth_entity.dart';

abstract interface class IAuthRepository {
  Future<Either<Failure, bool>> register(AuthEntity entity);
  Future<Either<Failure, AuthEntity>> login(String email, String password);
  Future<Either<Failure, bool>> logout();
  Future<Either<Failure, AuthEntity>> getCurrentUser();
}
