import 'dart:async';
import 'package:flutter/material.dart';
import 'package:localkart/feature/onboarding/presentation/pages/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..forward();

    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const OnboardingScreen(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _backgroundGlow({
    required double size,
    required double top,
    required double left,
    required double opacity,
  }) {
    return Positioned(
      top: top,
      left: left,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF4CAF50).withOpacity(opacity),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4CAF50).withOpacity(opacity),
              blurRadius: 120,
              spreadRadius: 60,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// Base background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFFFFF),
                  Color(0xFFF9FCF8),
                  Color(0xFFFFFFFF),
                ],
              ),
            ),
          ),

          /// Left glow (matches screenshot)
          _backgroundGlow(
            size: 220,
            top: 150,
            left: -120,
            opacity: 0.08,
          ),

          /// Bottom-right glow
          _backgroundGlow(
            size: 260,
            top: 600,
            left: 220,
            opacity: 0.06,
          ),

          /// Additional subtle center glow
          Positioned(
            bottom: 120,
            left: 80,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF81C784).withOpacity(0.05),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF81C784).withOpacity(0.08),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
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
                        color: Color(0xFF666666),
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
                              backgroundColor: const Color(0xFFE0E0E0),
                              valueColor:
                                  const AlwaysStoppedAnimation<Color>(
                                Color(0xFF2E7D32),
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
                        color: Color(0xFF8A8A8A),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}