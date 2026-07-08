

import 'package:localkart/feature/auth/data/models/auth_api_model.dart';
import 'package:localkart/feature/auth/data/models/auth_hive_model.dart';

abstract interface class IAuthLocalDatasource {
  Future<bool> register(AuthHiveModel model);
  Future<AuthHiveModel?> login(String email, String password);
  Future<bool> logout();
  Future<bool> isEmailExists(String email);
  Future<AuthHiveModel?> getCurrentUser();
}

abstract interface class IAuthRemoteDatasource {
  Future<AuthApiModel?> register(AuthApiModel model);
  Future<AuthApiModel?> login(String email, String password);
  Future<bool> isEmailExists(String email);
  Future<AuthApiModel?> getCurrentUser();
  Future<void> requestPasswordResetOtp(String email);
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  });
}
