import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/app/theme/app_colors.dart';
import 'package:localkart/core/utils/snackbar_utils.dart';
import 'package:localkart/core/widgets/app_background.dart';
import 'package:localkart/core/widgets/custom_button.dart';
import 'package:localkart/core/widgets/custom_text_field.dart';
import 'package:localkart/feature/auth/presentation/states/auth_state.dart';
import 'package:localkart/feature/auth/presentation/view_model/auth_view_model.dart';
import 'login_screen.dart';

class ForgetPasswordScreen extends ConsumerStatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  ConsumerState<ForgetPasswordScreen> createState() =>
      _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends ConsumerState<ForgetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _otpSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.otpSent) {
        setState(() => _otpSent = true);
        SnackbarUtils.showSuccess(context, 'OTP sent successfully!');
      } else if (next.status == AuthStatus.passwordReset) {
        SnackbarUtils.showSuccess(context, 'Password reset successfully!');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else if (next.status == AuthStatus.error && next.errorMessage != null) {
        SnackbarUtils.showError(context, next.errorMessage!);
      }
    });

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 20,
            ),
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
                    child: Image.asset(
                      "assets/images/logo.png",
                      height: 90,
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// Card
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
                        Text(
                          _otpSent ? "Reset Password" : "Forgot Password?",
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          _otpSent
                              ? "Enter OTP and new password"
                              : "Enter your email to get OTP",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 30),

                        if (!_otpSent) ...[
                          /// Email
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Email Address",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          CustomTextField(
                            hint: "name@example.com",
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            controller: _emailController,
                            validator: (value) =>
                                (value == null || value.trim().isEmpty)
                                    ? "Email is required"
                                    : null,
                          ),
                        ],

                        if (_otpSent) ...[
                          /// OTP
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "OTP",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          CustomTextField(
                            hint: "Enter OTP",
                            prefixIcon: Icons.confirmation_number_outlined,
                            keyboardType: TextInputType.number,
                            controller: _otpController,
                            validator: (value) =>
                                (value == null || value.trim().isEmpty)
                                    ? "OTP is required"
                                    : null,
                          ),
                          const SizedBox(height: 20),

                          /// New Password
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "New Password",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          CustomTextField(
                            hint: "••••••••",
                            prefixIcon: Icons.lock_outline,
                            isPassword: true,
                            controller: _newPasswordController,
                            validator: (value) =>
                                (value == null || value.isEmpty)
                                    ? "Password is required"
                                    : null,
                          ),
                          const SizedBox(height: 20),

                          /// Confirm Password
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Confirm Password",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          CustomTextField(
                            hint: "••••••••",
                            prefixIcon: Icons.lock_outline,
                            isPassword: true,
                            controller: _confirmPasswordController,
                            validator: (value) =>
                                (value == null || value.isEmpty)
                                    ? "Please confirm your password"
                                    : null,
                          ),
                        ],

                        const SizedBox(height: 28),

                        /// Button
                        CustomButton(
                          text: _otpSent ? "Reset Password" : "Send OTP",
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              if (!_otpSent) {
                                ref
                                    .read(authViewModelProvider.notifier)
                                    .requestPasswordReset(
                                      email:
                                          _emailController.text.trim(),
                                    );
                              } else {
                                ref
                                    .read(authViewModelProvider.notifier)
                                    .resetPassword(
                                      email:
                                          _emailController.text.trim(),
                                      otp: _otpController.text.trim(),
                                      newPassword:
                                          _newPasswordController.text,
                                      confirmPassword:
                                          _confirmPasswordController
                                              .text,
                                    );
                              }
                            }
                          },
                        ),

                        const SizedBox(height: 24),

                        /// Login Navigation
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Remembered Password? ",
                              style: TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            GestureDetector(
                              onTap: () =>
                                  Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const LoginScreen(),
                                ),
                              ),
                              child: const Text(
                                "Login",
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
    );
  }
}
