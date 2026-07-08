import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/core/services/storage/token_service.dart';
import 'package:localkart/feature/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:localkart/feature/auth/domain/usecases/logout_usecase.dart';
import 'package:localkart/feature/auth/domain/usecases/request_password_reset_usecase.dart';
import 'package:localkart/feature/auth/domain/usecases/reset_password_usecase.dart';
import 'package:localkart/feature/auth/presentation/states/auth_state.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  () => AuthViewModel(),
);

class AuthViewModel extends Notifier<AuthState> {
  late final RegisterUsecase _registerUsecase;
  late final LoginUsecase _loginUsecase;
  late final GetCurrentUserUsecase _getCurrentUserUsecase;
  late final LogoutUsecase _logoutUsecase;
  late final RequestPasswordResetUsecase _requestPasswordResetUsecase;
  late final ResetPasswordUsecase _resetPasswordUsecase;

  @override
  AuthState build() {
    _registerUsecase = ref.read(registerUsecaseProvider);
    _loginUsecase = ref.read(loginUsecaseProvider);
    _getCurrentUserUsecase = ref.read(getCurrentUserUsecaseProvider);
    _logoutUsecase = ref.read(logoutUsecaseProvider);
    _requestPasswordResetUsecase = ref.read(requestPasswordResetUsecaseProvider);
    _resetPasswordUsecase = ref.read(resetPasswordUsecaseProvider);
    return AuthState();
  }

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String username,
    required String password,
    required String confirmPassword,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    await Future.delayed(Duration(seconds: 2));
    final params = RegisterUsecaseParams(
      name: name,
      email: email,
      phone: phone,
      username: username,
      password: password,
      confirmPassword: confirmPassword,
    );
    final result = await _registerUsecase(params);
    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (isRegistered) {
        if (isRegistered) {
          state = state.copyWith(status: AuthStatus.registered);
        }
      },
    );
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading);
    await Future.delayed(Duration(seconds: 2));
    final params = LoginUsecaseParams(email: email, password: password);
    final result = await _loginUsecase(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (authEntity) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          authEntity: authEntity,
        );
      },
    );
  }

  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _logoutUsecase();

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (success) => state = state.copyWith(
        status: AuthStatus.unauthenticated,
        authEntity: null,
      ),
    );
  }

  Future<void> fetchCurrentUser() async {
    final token = ref.read(tokenServiceProvider).getToken();
    if (token == null || token.trim().isEmpty) {
      return;
    }

    final result = await _getCurrentUserUsecase();

    result.fold(
      (failure) => state = state.copyWith(errorMessage: failure.message),
      (authEntity) => state = state.copyWith(
        status: AuthStatus.authenticated,
        authEntity: authEntity,
      ),
    );
  }

  Future<void> requestPasswordReset({required String email}) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    final params = RequestPasswordResetParams(email: email);
    final result = await _requestPasswordResetUsecase(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (_) {
        state = state.copyWith(status: AuthStatus.otpSent);
      },
    );
  }

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    final params = ResetPasswordParams(
      email: email,
      otp: otp,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
    final result = await _resetPasswordUsecase(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (_) {
        state = state.copyWith(status: AuthStatus.passwordReset);
      },
    );
  }
}
