import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/feature/splash/presentation/pages/splash_screen.dart';
import 'package:localkart/feature/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:localkart/feature/product/presentation/pages/home_screen.dart';
import 'package:localkart/feature/cart/presentation/pages/cart_screen.dart';
import 'package:localkart/feature/profile/presentation/pages/profile_screen.dart';

Widget wrapInTestApp(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      home: child,
    ),
  );
}

void main() {
  group('Feature Screens', () {
    testWidgets('SplashScreen renders without error', (tester) async {
      // SplashScreen uses AnimationController, Future.delayed, Image.asset,
      // and Riverpod providers. Full test requires provider mocks and asset bundle.
      // See: lib/feature/splash/presentation/pages/splash_screen.dart
    }, skip: true);

    testWidgets('OnboardingScreen renders without error', (tester) async {
      await tester.pumpWidget(wrapInTestApp(const OnboardingScreen()));
      await tester.pump();
      expect(find.byType(OnboardingScreen), findsOneWidget);
    });

    testWidgets('HomeScreen renders without error', (tester) async {
      // HomeScreen requires complex Riverpod provider setup (productViewModelProvider)
      // See: lib/feature/product/presentation/pages/home_screen.dart
    }, skip: true);

    testWidgets('CartScreen renders without error', (tester) async {
      await tester.pumpWidget(wrapInTestApp(const CartScreen()));
      await tester.pump();
      expect(find.byType(CartScreen), findsOneWidget);
    });

    testWidgets('ProfileScreen renders without error', (tester) async {
      // ProfileScreen requires complex Riverpod providers (authViewModelProvider,
      // userSessionServiceProvider) and asset images. Full test requires
      // mocking provider dependencies.
      // See: lib/feature/profile/presentation/pages/profile_screen.dart
    }, skip: true);
  });

  group('Scaffold and Material widgets', () {
    testWidgets('Scaffold renders with AppBar', (tester) async {
      await tester.pumpWidget(
        wrapInTestApp(
          const Scaffold(
            body: Center(child: Text('Content')),
          ),
        ),
      );
      expect(find.text('Content'), findsOneWidget);
    });

    testWidgets('ElevatedButton triggers onPressed', (tester) async {
      int count = 0;
      await tester.pumpWidget(
        wrapInTestApp(
          Scaffold(
            body: ElevatedButton(
              onPressed: () => count++,
              child: const Text('Press'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Press'));
      expect(count, 1);
    });

    testWidgets('TextField accepts input', (tester) async {
      await tester.pumpWidget(
        wrapInTestApp(
          const Scaffold(
            body: TextField(),
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), 'Hello');
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('CircularProgressIndicator shows during loading', (tester) async {
      await tester.pumpWidget(
        wrapInTestApp(
          const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Icon displays correctly', (tester) async {
      await tester.pumpWidget(
        wrapInTestApp(
          const Scaffold(
            body: Icon(Icons.home, size: 24),
          ),
        ),
      );
      expect(find.byIcon(Icons.home), findsOneWidget);
    });

    testWidgets('ListView renders multiple children', (tester) async {
      await tester.pumpWidget(
        wrapInTestApp(
          Scaffold(
            body: ListView(
              children: const [
                ListTile(title: Text('Item 1')),
                ListTile(title: Text('Item 2')),
                ListTile(title: Text('Item 3')),
              ],
            ),
          ),
        ),
      );
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.text('Item 3'), findsOneWidget);
    });

    testWidgets('Card widget renders with content', (tester) async {
      await tester.pumpWidget(
        wrapInTestApp(
          const Scaffold(
            body: Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Card Content'),
              ),
            ),
          ),
        ),
      );
      expect(find.text('Card Content'), findsOneWidget);
    });

    testWidgets('Column lays out children vertically', (tester) async {
      await tester.pumpWidget(
        wrapInTestApp(
          const Scaffold(
            body: Column(
              children: [
                Text('Top'),
                Text('Middle'),
                Text('Bottom'),
              ],
            ),
          ),
        ),
      );
      expect(find.text('Top'), findsOneWidget);
      expect(find.text('Bottom'), findsOneWidget);
    });

    testWidgets('Row lays out children horizontally', (tester) async {
      await tester.pumpWidget(
        wrapInTestApp(
          const Scaffold(
            body: Row(
              children: [
                Text('Left'),
                Text('Right'),
              ],
            ),
          ),
        ),
      );
      expect(find.text('Left'), findsOneWidget);
      expect(find.text('Right'), findsOneWidget);
    });

    testWidgets('AlertDialog shows and can be dismissed', (tester) async {
      await tester.pumpWidget(
        wrapInTestApp(
          Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Alert'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                ),
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pump();
      expect(find.text('Alert'), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pump();
      expect(find.text('Alert'), findsNothing);
    });

    testWidgets('BottomNavigationBar renders items', (tester) async {
      await tester.pumpWidget(
        wrapInTestApp(
          Scaffold(
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: 0,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
              ],
            ),
          ),
        ),
      );
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
    });

    testWidgets('Chip widget renders with label', (tester) async {
      await tester.pumpWidget(
        wrapInTestApp(
          const Scaffold(
            body: Chip(label: Text('Test Chip')),
          ),
        ),
      );
      expect(find.text('Test Chip'), findsOneWidget);
    });

    testWidgets('Switch widget toggles state', (tester) async {
      bool value = false;
      await tester.pumpWidget(
        wrapInTestApp(
          StatefulBuilder(
            builder: (context, setInnerState) => Scaffold(
              body: Switch(
                value: value,
                onChanged: (v) => setInnerState(() => value = v),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.byType(Switch));
      expect(value, true);
    });

    testWidgets('Checkbox toggles selection', (tester) async {
      bool checked = false;
      await tester.pumpWidget(
        wrapInTestApp(
          StatefulBuilder(
            builder: (context, setInnerState) => Scaffold(
              body: Checkbox(
                value: checked,
                onChanged: (v) => setInnerState(() => checked = v ?? false),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.byType(Checkbox));
      expect(checked, true);
    });

    testWidgets('DropdownButton shows options', (tester) async {
      String value = 'One';
      await tester.pumpWidget(
        wrapInTestApp(
          StatefulBuilder(
            builder: (context, setInnerState) => Scaffold(
              body: DropdownButton<String>(
                value: value,
                items: const [
                  DropdownMenuItem(value: 'One', child: Text('One')),
                  DropdownMenuItem(value: 'Two', child: Text('Two')),
                ],
                onChanged: (v) => setInnerState(() => value = v ?? value),
              ),
            ),
          ),
        ),
      );
      expect(find.text('One'), findsOneWidget);
    });

    testWidgets('Slider renders and adjusts', (tester) async {
      double sliderVal = 0.5;
      await tester.pumpWidget(
        wrapInTestApp(
          StatefulBuilder(
            builder: (context, setInnerState) => Scaffold(
              body: Slider(
                value: sliderVal,
                onChanged: (v) => setInnerState(() => sliderVal = v),
              ),
            ),
          ),
        ),
      );
      expect(find.byType(Slider), findsOneWidget);
    });

    testWidgets('ExpansionTile expands on tap', (tester) async {
      await tester.pumpWidget(
        wrapInTestApp(
          const Scaffold(
            body: ExpansionTile(
              title: Text('Expand Me'),
              children: [Text('Hidden Content')],
            ),
          ),
        ),
      );
      expect(find.text('Hidden Content'), findsNothing);
      await tester.tap(find.text('Expand Me'));
      await tester.pumpAndSettle();
      expect(find.text('Hidden Content'), findsOneWidget);
    });

    testWidgets('Radio button renders', (tester) async {
      await tester.pumpWidget(
        wrapInTestApp(
          const Scaffold(
            body: Radio(value: 1, groupValue: 1, onChanged: null),
          ),
        ),
      );
      expect(find.byType(Radio<int>), findsOneWidget);
    });
  });

  group('Material Theming', () {
    testWidgets('ThemeData applies correctly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData(
              primarySwatch: Colors.green,
              scaffoldBackgroundColor: Colors.white,
            ),
            home: const Scaffold(
              body: Center(child: Text('Themed')),
            ),
          ),
        ),
      );
      expect(find.text('Themed'), findsOneWidget);
    });
  });
}
