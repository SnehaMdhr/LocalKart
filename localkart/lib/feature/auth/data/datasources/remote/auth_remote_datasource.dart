import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/core/api/api_client.dart';
import 'package:localkart/core/api/api_endpoints.dart';
import 'package:localkart/core/services/storage/token_service.dart';
import 'package:localkart/core/services/storage/user_session_service.dart';
import 'package:localkart/feature/auth/data/datasources/auth_datasource.dart';
import 'package:localkart/feature/auth/data/models/auth_api_model.dart';


final authRemoteDatasourceProvider = Provider<IAuthRemoteDatasource>((ref) {
  return AuthRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    userSessionService: ref.read(userSessionServiceProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

class AuthRemoteDatasource implements IAuthRemoteDatasource {
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;
  final TokenService _tokenService;
  AuthRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
    required TokenService tokenService,
  }) : _apiClient = apiClient,
       _userSessionService = userSessionService,
       _tokenService = tokenService;

  @override
  Future<bool> isEmailExists(String email) {
    // TODO: implement isEmailExists
    throw UnimplementedError();
  }

  @override
  Future<AuthApiModel?> login(String email, String password) async {
    final response = await _apiClient.post(
      ApiEndpoints.userLogin,
      data: {"email": email, "password": password},
    );

    if (response.data["success"] == true) {
      final data = response.data["data"] as Map<String, dynamic>;
      final user = AuthApiModel.fromJson(data);

      //save the session
      if (user.id != null) {
        await _userSessionService.saveUserSession(
          userId: user.id!,
          email: user.email,
          name: user.name,
          phone:user.phone,
          username: user.username,
          profilePicture: user.imageUrl,
        );
      } else {
        // Handle the case where user.id is null
      }
      final token = response.data["token"] as String?;
      await _tokenService.saveToken(token!);
      return user;
    }
    return null;
  }

  @override
  Future<AuthApiModel?> register(AuthApiModel model) async {
    final response = await _apiClient.post(
      ApiEndpoints.userRegister,
      data: model.toJson(),
    );
    if (response.data["success"] == true) {
      final data = response.data["data"] as Map<String, dynamic>;
      final registeredUser = AuthApiModel.fromJson(data);
      return registeredUser;
    }
    return model;
  }

  @override
  Future<AuthApiModel?> getCurrentUser() async {
    final response = await _apiClient.get(ApiEndpoints.getCurrentUser);
    if (response.data == null) {
      return null;
    }

    final payload = response.data;

    if (payload is Map<String, dynamic>) {
      if (payload['data'] is Map<String, dynamic>) {
        return AuthApiModel.fromJson(payload['data'] as Map<String, dynamic>);
      }
      return AuthApiModel.fromJson(payload);
    }

    return null;
  }

  @override
  Future<void> requestPasswordResetOtp(String email) async {
    await _apiClient.post(
      ApiEndpoints.requestPasswordReset,
      data: {"email": email},
    );
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await _apiClient.post(
      ApiEndpoints.resetPassword,
      data: {
        "email": email,
        "otp": otp,
        "newPassword": newPassword,
        "confirmPassword": confirmPassword,
      },
    );
  }
}
