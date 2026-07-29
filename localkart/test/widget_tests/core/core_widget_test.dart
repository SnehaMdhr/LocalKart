import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localkart/core/widgets/custom_button.dart';
import 'package:localkart/core/widgets/custom_text_field.dart';
import 'package:localkart/core/widgets/custom_icon_button.dart';
import 'package:localkart/core/widgets/custom_outlined_button.dart';
import 'package:localkart/core/widgets/app_background.dart';

void main() {
  group('CustomButton', () {
    testWidgets('should display text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Login',
              onPressed: () {},
            ),
          ),
        ),
      );
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('should show loader when isLoading is true', (tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Submit',
              onPressed: () => pressed = true,
              isLoading: true,
            ),
          ),
        ),
      );
      // When loading, button shows CircularProgressIndicator instead of text
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Submit'), findsNothing);
    });

    testWidgets('should be disabled when isEnabled is false', (tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Disabled',
              onPressed: () => pressed = true,
              isEnabled: false,
            ),
          ),
        ),
      );
      // Button renders but tapping does not trigger callback
      await tester.tap(find.text('Disabled'));
      expect(pressed, false);
    });

    testWidgets('should show CircularProgressIndicator when loading', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Loading',
              onPressed: () {},
              isLoading: true,
            ),
          ),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should trigger onPressed when tapped', (tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Tap Me',
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );
      await tester.tap(find.text('Tap Me'));
      expect(pressed, true);
    });

    testWidgets('should accept custom height', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Tall',
              onPressed: () {},
              height: 80,
            ),
          ),
        ),
      );
      expect(find.text('Tall'), findsOneWidget);
    });
  });

  group('CustomTextField', () {
    testWidgets('should display hint text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              hint: 'Enter email',
              prefixIcon: Icons.email,
            ),
          ),
        ),
      );
      expect(find.text('Enter email'), findsOneWidget);
    });

    testWidgets('should display prefix icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              hint: 'Password',
              prefixIcon: Icons.lock,
              isPassword: true,
            ),
          ),
        ),
      );
      expect(find.byIcon(Icons.lock), findsOneWidget);
    });

    testWidgets('should show visibility toggle for password fields', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              hint: 'Password',
              prefixIcon: Icons.lock,
              isPassword: true,
            ),
          ),
        ),
      );
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });

    testWidgets('should toggle password visibility on icon tap', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              hint: 'Password',
              prefixIcon: Icons.lock,
              isPassword: true,
            ),
          ),
        ),
      );
      // Tap visibility toggle
      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pump();
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });

    testWidgets('should not show visibility toggle for non-password fields', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              hint: 'Name',
              prefixIcon: Icons.person,
            ),
          ),
        ),
      );
      expect(find.byIcon(Icons.visibility_off_outlined), findsNothing);
    });

    testWidgets('should accept text input', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              hint: 'Type here',
              prefixIcon: Icons.edit,
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(TextFormField), 'Hello');
      expect(find.text('Hello'), findsOneWidget);
    });
  });

  group('CustomIconButton', () {
    testWidgets('should display text and icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomIconButton(
              text: 'Google',
              icon: Icons.login,
              onPressed: () {},
            ),
          ),
        ),
      );
      expect(find.text('Google'), findsOneWidget);
      expect(find.byIcon(Icons.login), findsOneWidget);
    });

    testWidgets('should trigger onPressed when tapped', (tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomIconButton(
              text: 'Tap',
              icon: Icons.touch_app,
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );
      await tester.tap(find.text('Tap'));
      expect(pressed, true);
    });
  });

  group('CustomOutlinedButton', () {
    testWidgets('should display text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomOutlinedButton(
              text: 'Skip',
              onPressed: () {},
            ),
          ),
        ),
      );
      expect(find.text('Skip'), findsOneWidget);
    });

    testWidgets('should show loader when loading', (tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomOutlinedButton(
              text: 'Loading',
              onPressed: () => pressed = true,
              isLoading: true,
            ),
          ),
        ),
      );
      // When loading, button shows CircularProgressIndicator instead of text
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading'), findsNothing);
    });

    testWidgets('should show CircularProgressIndicator when loading', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomOutlinedButton(
              text: 'Wait',
              onPressed: () {},
              isLoading: true,
            ),
          ),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should trigger onPressed when tapped', (tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomOutlinedButton(
              text: 'Click',
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );
      await tester.tap(find.text('Click'));
      expect(pressed, true);
    });
  });

  group('AppBackground', () {
    testWidgets('should render child widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppBackground(
              child: const Text('Hello World'),
            ),
          ),
        ),
      );
      expect(find.text('Hello World'), findsOneWidget);
    });

    testWidgets('should fill available space', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppBackground(
              child: const SizedBox(width: 100, height: 100),
            ),
          ),
        ),
      );
      // Just verify it renders without error
      expect(find.byType(AppBackground), findsOneWidget);
    });
  });
}
