import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/core/services/connectivity/network_info.dart';
import 'package:localkart/feature/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:localkart/feature/auth/data/models/auth_api_model.dart';
import 'package:localkart/feature/auth/data/models/auth_hive_model.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_datasource.dart';
import '../datasources/local/auth_local_datasource.dart';

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final authDatasource = ref.read(authLocalDatasourceProvider);
  final authRemoteDatasource = ref.read(authRemoteDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  return AuthRepository(
    authLocalDatasource: authDatasource,
    authRemoteDatasource: authRemoteDatasource,
    networkInfo: networkInfo,
  );
});

class AuthRepository implements IAuthRepository {
  final IAuthLocalDatasource _authLocalDatasource;
  final IAuthRemoteDatasource _authRemoteDataSource;
  final NetworkInfo _networkInfo;
  AuthRepository({
    required IAuthLocalDatasource authLocalDatasource,
    required IAuthRemoteDatasource authRemoteDatasource,
    required NetworkInfo networkInfo,
  }) : _authLocalDatasource = authLocalDatasource,
       _authRemoteDataSource = authRemoteDatasource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, AuthEntity>> login(
    String email,
    String password,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = await _authRemoteDataSource.login(email, password);
        if (apiModel != null) {
          final entity = apiModel.toEntity();
          return Right(entity);
        }
        return Left(ApiFailure(message: "Invalid Credentials"));
      } on DioException catch (e) {
        return left(
          ApiFailure(
            message: e.response?.data["message"] ?? "Login Failed",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final user = await _authLocalDatasource.login(email, password);
        if (user != null) {
          final entity = user.toEntity();
          return Right(entity);
        }
        return Left(LocalDatabaseFailure(message: "Invalid email or password"));
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> register(AuthEntity entity) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = AuthApiModel.fromEntity(entity);
        await _authRemoteDataSource.register(apiModel);
        return const Right(true);
      } on DioException catch (e) {
        return left(
          ApiFailure(
            message: e.response?.data["message"] ?? "Register Failed",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final model = AuthHiveModel.fromEntity(entity);
        final result = await _authLocalDatasource.register(model);
        if (result) {
          return Right(true);
        }
        return Left(LocalDatabaseFailure(message: "Failed to register user"));
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      final result = await _authLocalDatasource.logout();
      if (result) {
        return const Right(true);
      }
      return Left(LocalDatabaseFailure(message: "Failed to logout"));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    if (await _networkInfo.isConnected) {
      try {
        final user = await _authRemoteDataSource.getCurrentUser();
        if (user != null) {
          final entity = user.toEntity();
          return Right(entity);
        }
        return (Left(ApiFailure(message: "No current user found")));
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final user = await _authLocalDatasource.getCurrentUser();
        if (user != null) {
          final entity = user.toEntity();
          return Right(entity);
        }
        return (Left(LocalDatabaseFailure(message: 'No current user found')));
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, void>> requestPasswordResetOtp(String email) async {
    if (!await _networkInfo.isConnected) {
      return Left(NetworkFailure(message: "No internet connection"));
    }
    try {
      await _authRemoteDataSource.requestPasswordResetOtp(email);
      return const Right(null);
    } on DioException catch (e) {
      return left(
        ApiFailure(
          message: e.response?.data["message"] ?? "Failed to send OTP",
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (!await _networkInfo.isConnected) {
      return Left(NetworkFailure(message: "No internet connection"));
    }
    try {
      await _authRemoteDataSource.resetPassword(
        email: email,
        otp: otp,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      return const Right(null);
    } on DioException catch (e) {
      return left(
        ApiFailure(
          message: e.response?.data["message"] ?? "Failed to reset password",
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}
