import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/app/theme/app_colors.dart';
import 'package:localkart/core/services/storage/user_session_service.dart';
import 'package:localkart/core/utils/snackbar_utils.dart';
import 'package:localkart/core/widgets/app_background.dart';
import 'package:localkart/core/widgets/bottom_navigation_bar_for_customer.dart';
import 'package:localkart/core/widgets/bottom_navigation_bar_for_vendor.dart';
import 'package:localkart/core/widgets/custom_button.dart';
import 'package:localkart/core/widgets/custom_text_field.dart';
import 'package:localkart/feature/auth/presentation/pages/forget_password_screen.dart';
import 'package:localkart/feature/auth/presentation/pages/register_screen.dart';
import 'package:localkart/feature/auth/presentation/states/auth_state.dart';
import 'package:localkart/feature/auth/presentation/view_model/auth_view_model.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      await ref
          .read(authViewModelProvider.notifier)
          .login(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final isLoading = authState.status == AuthStatus.loading;

    ref.listen<AuthState>(authViewModelProvider, (previous, next) async {
      if (next.status == AuthStatus.error) {
        SnackbarUtils.showError(
          context,
          next.errorMessage ?? "Login failed",
          duration: const Duration(seconds: 1),
        );
      } else if (next.status == AuthStatus.authenticated &&
          next.authEntity != null) {
        SnackbarUtils.showSuccess(
          context,
          "Login successful",
          duration: const Duration(seconds: 1),
        );

        final user = next.authEntity!;

        await ref
            .read(userSessionServiceProvider)
            .saveUserSession(
              userId: user.userId ?? '',
              email: user.email,
              name: user.name,
              phone: user.phone,
              username: user.username,
              role: user.role,
              profilePicture: user.imageUrl,
            );

        final role = user.role ?? 'Customer';
        Widget destination;
        if (role == 'Customer') {
          destination = const BottomNavigationBarForCustomer();
        } else {
          destination = const BottomNavigationBarForVendor();
        }

        Navigator.push(context, MaterialPageRoute(builder: (_) => destination));
      }
    });
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    /// Logo
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.15),
                            blurRadius: 50,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Image.asset("assets/images/logo.png", height: 90),
                    ),

                    const SizedBox(height: 30),

                    /// Login Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.96),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.textPrimary.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Welcome Back",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),

                          const SizedBox(height: 10),

                          const Text(
                            "Sign in to your account to continue shopping!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: 30),

                          /// Email
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Email Address",
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),

                          const SizedBox(height: 8),

                          CustomTextField(
                            controller: emailController,
                            hint: "name@example.com",
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Email is required";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          /// Password Label
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Password",
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const ForgetPasswordScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Forgot Password?",
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          CustomTextField(
                            controller: passwordController,
                            hint: "••••••••",
                            prefixIcon: Icons.lock_outline,
                            isPassword: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Password is required";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 28),

                          /// Login Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: CustomButton(
                              text: "Login",
                              isLoading: isLoading,
                              onPressed: _handleLogin,
                            ),
                          ),

                          const SizedBox(height: 24),

                          /// Divider
                          Row(
                            children: [
                              Expanded(
                                child: Divider(color: AppColors.divider),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Text("OR"),
                              ),
                              Expanded(
                                child: Divider(color: AppColors.divider),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          /// Google Button
                          OutlinedButton.icon(
                            onPressed: () {
                              ref
                                  .read(authViewModelProvider.notifier)
                                  .loginWithGoogle();
                            },
                            icon: Image.asset(
                              "assets/images/google.png",
                              height: 30,
                            ),
                            label: const Text(
                              "Continue with Google",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 56),
                              side: BorderSide(color: AppColors.divider),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                          ),

                          const SizedBox(height: 25),

                          /// Register Navigation
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Don't have an account? ",
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const RegisterScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Register now",
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
