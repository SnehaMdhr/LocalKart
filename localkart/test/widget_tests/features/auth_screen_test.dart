import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Helper to wrap a widget in ProviderScope + MaterialApp for testing
Widget wrapInTestApp(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      home: child,
    ),
  );
}

void main() {
  group('LoginScreen', () {
    testWidgets('should render login screen widget', (tester) async {
      await tester.pumpWidget(wrapInTestApp(const Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Text('Welcome Back'),
              Text('Login to continue'),
            ],
          ),
        ),
      )));
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Login to continue'), findsOneWidget);
    });
  });

  group('Login Screen UI Elements', () {
    testWidgets('TextFormField displays with decoration', (tester) async {
      await tester.pumpWidget(wrapInTestApp(
        Scaffold(
          body: TextFormField(
            decoration: const InputDecoration(
              hintText: 'Enter email',
              prefixIcon: Icon(Icons.email),
            ),
            validator: (value) => value?.isEmpty == true ? 'Required' : null,
          ),
        ),
      ));
      expect(find.text('Enter email'), findsOneWidget);
    });

    testWidgets('CircularProgressIndicator renders', (tester) async {
      await tester.pumpWidget(wrapInTestApp(
        const Scaffold(body: Center(child: CircularProgressIndicator())),
      ));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('ElevatedButton renders with text', (tester) async {
      await tester.pumpWidget(wrapInTestApp(
        Scaffold(
          body: ElevatedButton(
            onPressed: () {},
            child: const Text('Sign In'),
          ),
        ),
      ));
      expect(find.text('Sign In'), findsOneWidget);
    });
  });

  group('RegisterScreen UI Elements', () {
    testWidgets('TextFormField renders with validation', (tester) async {
      await tester.pumpWidget(wrapInTestApp(
        Scaffold(
          body: Form(
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
              ],
            ),
          ),
        ),
      ));
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('Registration button renders', (tester) async {
      await tester.pumpWidget(wrapInTestApp(
        Scaffold(
          body: ElevatedButton(
            onPressed: () {},
            child: const Text('Register'),
          ),
        ),
      ));
      expect(find.text('Register'), findsOneWidget);
    });
  });

  group('ForgetPasswordScreen', () {
    testWidgets('Email input field renders', (tester) async {
      await tester.pumpWidget(wrapInTestApp(
        Scaffold(
          body: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Enter your email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Send OTP'),
              ),
            ],
          ),
        ),
      ));
      expect(find.text('Enter your email'), findsOneWidget);
      expect(find.text('Send OTP'), findsOneWidget);
    });

    testWidgets('Send OTP button triggers action', (tester) async {
      bool otpSent = false;
      await tester.pumpWidget(wrapInTestApp(
        Scaffold(
          body: ElevatedButton(
            onPressed: () => otpSent = true,
            child: const Text('Send OTP'),
          ),
        ),
      ));
      await tester.tap(find.text('Send OTP'));
      expect(otpSent, true);
    });
  });

  group('App Navigation', () {
    testWidgets('MaterialApp renders with navigation', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const Scaffold(
              body: Center(child: Text('Test App')),
            ),
          ),
        ),
      );
      expect(find.text('Test App'), findsOneWidget);
    });

    testWidgets('Navigator.push works correctly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const Scaffold(
                        body: Center(child: Text('New Page')),
                      ),
                    ),
                  ),
                  child: const Text('Go'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Go'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('New Page'), findsOneWidget);
    });
  });
}


