import 'package:flutter/material.dart';

/// A wrapper widget that gives each tab its own [Navigator].
/// Screens pushed via [pushTabScreen] stay within the tab and
/// do NOT cover the bottom navigation bar.
class TabNavigator extends StatefulWidget {
  final Widget screen;

  const TabNavigator({super.key, required this.screen});

  /// Push a new screen within the current tab's Navigator.
  /// The bottom nav bar will remain visible.
  static Future<T?> pushTabScreen<T>(
    BuildContext context,
    Widget screen,
  ) {
    return Navigator.push<T>(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  /// Replace the current screen within the tab (no back button).
  static Future<T?> pushReplacementTabScreen<T, TO>(
    BuildContext context,
    Widget screen,
  ) {
    return Navigator.pushReplacement<T, TO>(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  /// Pop back to the root of the current tab.
  static void popToTabRoot(BuildContext context) {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  State<TabNavigator> createState() => _TabNavigatorState();
}

class _TabNavigatorState extends State<TabNavigator> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: _navigatorKey,
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (_) => widget.screen,
          settings: settings,
        );
      },
    );
  }
}
