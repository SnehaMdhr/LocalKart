import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/app/theme/app_colors.dart';
import 'package:localkart/core/utils/snackbar_utils.dart';
import 'package:localkart/core/widgets/app_background.dart';
import 'package:localkart/core/widgets/custom_button.dart';
import 'package:localkart/core/widgets/custom_text_field.dart';
import 'package:localkart/feature/auth/presentation/pages/login_screen.dart';
import 'package:localkart/feature/auth/presentation/states/auth_state.dart';
import 'package:localkart/feature/auth/presentation/view_model/auth_view_model.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      await ref
          .read(authViewModelProvider.notifier)
          .register(
            name: nameController.text.trim(),
            email: emailController.text.trim(),
            phone: phoneController.text.trim(),
            username: emailController.text.trim().split("@").first,
            password: passwordController.text.trim(),
            confirmPassword: confirmPasswordController.text.trim(),
          );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
     final authState = ref.watch(authViewModelProvider);
    final isLoading = authState.status == AuthStatus.loading;

    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.error) {
        SnackbarUtils.showError(
          context,
          next.errorMessage ?? "Registration failed",
          duration: const Duration(seconds: 1),
        );
      } else if (next.status == AuthStatus.registered) {
        SnackbarUtils.showSuccess(
          context,
          "Registration successful",
          duration: const Duration(seconds: 1),
        );
        Navigator.push(context,MaterialPageRoute(
            builder: (_) =>
              const LoginScreen(),
        ),
        );
      }
    });
    return Scaffold(
      body: AppBackground(
          child:SafeArea(
            child: SingleChildScrollView(
              child: Padding(
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

                    const SizedBox(height: 25),

                    /// Register Card
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
                            "Create Account",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),

                          const SizedBox(height: 10),

                          const Text(
                            "Fill in your details to get started",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),

                          const SizedBox(height: 30),

                          /// Name
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Name",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          CustomTextField(
                            controller: nameController,
                            hint: "Name",
                            prefixIcon: Icons.person_outline,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Name is required";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 18),

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
                          const SizedBox(height: 18),

                          /// Phone
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Phone Number",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          CustomTextField(
                            controller: phoneController,
                            hint: "9800000000",
                            prefixIcon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Phone number is required";
                              }
                              if (!RegExp(r'^\d{10}$').hasMatch(value.trim())) {
                                return "Phone number must be exactly 10 digits";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 18),

                          /// Password
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Password",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
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
                              if (value.length < 8) {
                                return "Password must be at least 8 characters";
                              }
                              if (!RegExp(r'[A-Z]').hasMatch(value)) {
                                return "Must contain at least 1 uppercase letter";
                              }
                              if (!RegExp(r'[a-z]').hasMatch(value)) {
                                return "Must contain at least 1 lowercase letter";
                              }
                              if (!RegExp(r'[0-9]').hasMatch(value)) {
                                return "Must contain at least 1 number";
                              }
                              if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                                return "Must contain at least 1 special character";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 18),

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
                            controller: confirmPasswordController,
                            hint: "••••••••",
                            prefixIcon: Icons.lock_outline,
                            isPassword: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Confirm your password";
                              }

                              if (value != passwordController.text) {
                                return "Passwords do not match";
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 28),

                          /// Register Button
                          CustomButton(
                            text: "Register",
                            isLoading: isLoading,
                            onPressed: _handleRegister,
                          ),

                          const SizedBox(height: 24),
                           /// Login Navigation
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Already have an account? ",
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(context,MaterialPageRoute(
                                      builder: (_) =>
                                        const LoginScreen(),
                                  ),);
                                },
                                child: const Text(
                                  "Login now",
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