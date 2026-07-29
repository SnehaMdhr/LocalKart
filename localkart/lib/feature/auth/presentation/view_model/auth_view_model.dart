import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:localkart/core/config/oauth_config.dart';
import 'package:localkart/core/services/socket_service.dart';
import 'package:localkart/core/services/storage/token_service.dart';
import 'package:localkart/feature/auth/data/repositories/auth_repository.dart';
import 'package:localkart/feature/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:localkart/feature/auth/domain/usecases/logout_usecase.dart';
import 'package:localkart/feature/auth/domain/usecases/request_password_reset_usecase.dart';
import 'package:localkart/feature/auth/domain/usecases/reset_password_usecase.dart';
import 'package:localkart/feature/auth/presentation/states/auth_state.dart';
import 'package:localkart/feature/notification/domain/entities/notification_entity.dart';
import 'package:localkart/feature/notification/presentation/view_model/notification_view_model.dart';
import 'package:localkart/feature/order/presentation/view_model/order_view_model.dart';
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

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: OAuthConfig.googleServerClientId,
  );

  
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
        // Connect Socket.IO after successful login
        _connectSocket();
      },
    );
  }

  void _connectSocket() {
    final socketService = ref.read(socketServiceProvider);
    final notifVM = ref.read(notificationViewModelProvider.notifier);
    final orderVM = ref.read(orderViewModelProvider.notifier);

    socketService.onNewNotification = (data) {
      final notifEntity = NotificationEntity(
        receiverId: data['receiverId'] ?? '',
        receiverRole: data['receiverRole'] ?? 'Customer',
        title: data['title'] ?? '',
        message: data['message'] ?? '',
        type: data['type'] ?? 'SYSTEM',
        orderId: data['orderId'] as String?,
        shopId: data['shopId'] as String?,
        orderNumber: data['orderNumber'] as String?,
        shopName: data['shopName'] as String?,
        isRead: data['isRead'] as bool? ?? false,
        notificationId: data['_id'] as String?,
        createdAt: data['createdAt'] as String?,
        updatedAt: data['updatedAt'] as String?,
      );
      notifVM.addNotificationFromSocket(notifEntity);
    };

    socketService.onUnreadCountUpdate = (count) {
      notifVM.updateUnreadCountFromSocket(count);
    };

    // ── Real-Time Order Events ──
    socketService.onNewOrder = (data) {
      print('[Socket] New order arrived via socket!');
      orderVM.insertIncomingOrder(data);
    };

    socketService.onOrderAccepted = (data) {
      print('[Socket] Order accepted via socket!');
      orderVM.removeAcceptedOrder(data);
    };

    socketService.onOrderRejected = (data) {
      print('[Socket] Order rejected via socket!');
      orderVM.removeOrderFromPending(data);
    };

    socketService.onOrderCancelled = (data) {
      print('[Socket] Order cancelled via socket!');
      orderVM.removeCancelledOrder(data);
    };

    socketService.onOrderUpdated = (data) {
      print('[Socket] Order updated via socket!');
      orderVM.updateOrderFromSocket(data);
    };

    socketService.connect();
  }

  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);

    // Disconnect Socket.IO before logout
    ref.read(socketServiceProvider).disconnect();

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
      (authEntity) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          authEntity: authEntity,
        );
        // Connect Socket.IO on app resume / token recovery
        _connectSocket();
      },
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

  Future<void> loginWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        state = state.copyWith(status: AuthStatus.unauthenticated);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Google sign-in failed: missing id token.',
        );
        return;
      }

      final result = await ref
          .read(authRepositoryProvider)
          .loginWithGoogle(idToken);

      result.fold(
        (failure) {
          state = state.copyWith(
            status: AuthStatus.error,
            errorMessage: failure.message,
          );
        },
        (user) {
          state = state.copyWith(
            status: AuthStatus.authenticated,
            authEntity: user,
            errorMessage: null,
          );
          // Connect Socket.IO after Google login
          _connectSocket();
        },
      );
    } on PlatformException catch (e) {
      final lowerCode = e.code.toLowerCase();
      final lowerMessage = (e.message ?? '').toLowerCase();
      final lowerDetails = (e.details?.toString() ?? '').toLowerCase();
      final isOAuthConfigIssue =
          lowerCode.contains('sign_in_failed') ||
          lowerMessage.contains('apiexception: 10') ||
          lowerMessage.contains('api exception: 10') ||
          lowerMessage.contains('apiexception') ||
          lowerDetails.contains('apiexception: 10') ||
          lowerDetails.contains('api exception: 10') ||
          lowerDetails.contains('apiexception') ||
          lowerMessage.contains('developer error') ||
          lowerDetails.contains('developer error') ||
          lowerMessage.contains('12500');

      final baseMessage = isOAuthConfigIssue
          ? 'Google sign-in failed: Android OAuth is not configured correctly. Verify package name and SHA-1/SHA-256 in Google Cloud.'
          : 'Google sign-in failed (${e.code}).';

      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage:
            '$baseMessage ${e.message != null ? 'Details: ${e.message}' : ''} ${e.details != null ? 'Extra: ${e.details}' : ''}',
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Google sign-in failed. Please try again. Details: $e',
      );
    }
  }
}
