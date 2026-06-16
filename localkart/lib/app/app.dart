import 'package:flutter/material.dart';
import 'package:localkart/app/theme/app_theme.dart';
import 'package:localkart/feature/splash/presentation/pages/splash_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LocalKart',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}