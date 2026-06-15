import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/app/theme/app_colors.dart';
import 'package:localkart/core/services/storage/user_session_service.dart';
import 'package:localkart/core/widgets/app_background.dart';
import 'package:localkart/core/widgets/bottom_navigation_bar_for_customer.dart';
import 'package:localkart/core/widgets/bottom_navigation_bar_for_vendor.dart';
import 'package:localkart/feature/auth/presentation/view_model/auth_view_model.dart';
import 'package:localkart/feature/onboarding/presentation/pages/onboarding_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..forward();

    _navigateToNext();
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 5));
    if (!mounted) return;

    final userSessionService = ref.read(userSessionServiceProvider);
    final isLoggedIn = userSessionService.isLoggedIn();

    if (isLoggedIn) {
      // Restore the auth state from the API/session
      if (mounted) {
        await ref.read(authViewModelProvider.notifier).fetchCurrentUser();
      }
      if (!mounted) return;

      final role = userSessionService.getCurrentUserRole() ?? 'Customer';
      Widget destination;
      if (role == 'Shopkeeper') {
        destination = const BottomNavigationBarForVendor();
      } else {
        destination = const BottomNavigationBarForCustomer();
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => destination),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const OnboardingScreen(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /// Logo
                  Image.asset(
                    'assets/images/logo.png',
                    height: 115,
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Groceries from nearby stores, delivered\nfast',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const SizedBox(height: 35),

                  /// Progress Bar
                  SizedBox(
                    width: 140,
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: LinearProgressIndicator(
                            value: _controller.value,
                            minHeight: 4,
                            backgroundColor: AppColors.divider,
                            valueColor:
                                const AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Syncing with local stores...',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}