import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/app/theme/app_colors.dart';
import 'package:localkart/core/widgets/title_app_bar.dart';
import 'package:localkart/feature/auth/presentation/pages/vendor_dashboard.dart';
import 'package:localkart/feature/order/presentation/pages/vendor_order_screen.dart';
import 'package:localkart/feature/profile/presentation/pages/vendor_profile_screen.dart';

class BottomNavigationBarForVendor extends ConsumerStatefulWidget {
  const BottomNavigationBarForVendor({super.key});

  @override
  ConsumerState<BottomNavigationBarForVendor> createState() =>
      _BottomNavigationBarForVendorState();
}

class _BottomNavigationBarForVendorState
    extends ConsumerState<BottomNavigationBarForVendor> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    VendorDashboard(),
    VendorOrderScreen(),
    VendorProfileScreen(),
  ];

  static const List<_NavTab> _tabs = [
    _NavTab(
      label: 'Dashboard',
      selectedIcon: Icons.dashboard_rounded,
      unselectedIcon: Icons.dashboard_outlined,
    ),
    _NavTab(
      label: 'Orders',
      selectedIcon: Icons.receipt_long_rounded,
      unselectedIcon: Icons.receipt_long_outlined,
    ),
    _NavTab(
      label: 'Profile',
      selectedIcon: Icons.person_rounded,
      unselectedIcon: Icons.person_outline_rounded,
    ),
  ];

  Future<bool> _onWillPop() async {
    if (_selectedIndex != 0) {
      setState(() => _selectedIndex = 0);
      return false;
    }

    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Do you want to exit the app?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Yes', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop) SystemNavigator.pop();
      },
      child: Scaffold(
        appBar: TitleAppBar(
          onNotificationTap: () {
            // TODO: Navigate to Notification Screen
          },
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: List.generate(_tabs.length, (index) {
          return Expanded(
            child: _NavItem(
              tab: _tabs[index],
              isSelected: _selectedIndex == index,
              onTap: () => setState(() => _selectedIndex = index),
            ),
          );
        }),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  Data class
// ═══════════════════════════════════════════════════════════════════════════════

class _NavTab {
  final String label;
  final IconData selectedIcon;
  final IconData unselectedIcon;

  const _NavTab({
    required this.label,
    required this.selectedIcon,
    required this.unselectedIcon,
  });
}

// ═══════════════════════════════════════════════════════════════════════════════
//  Nav item widget
// ═══════════════════════════════════════════════════════════════════════════════

class _NavItem extends StatefulWidget {
  final _NavTab tab;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.tab,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    if (widget.isSelected) {
      _animController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant _NavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _animController.forward();
      } else {
        _animController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool selected = widget.isSelected;

    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 + (_animController.value * 0.05),
            child: child,
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Icon with green circle background when selected ──
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: selected ? 44 : 28,
                  height: selected ? 44 : 28,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primaryLight
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    selected
                        ? widget.tab.selectedIcon
                        : widget.tab.unselectedIcon,
                    size: selected ? 22 : 24,
                    color: selected ? AppColors.white : AppColors.grey,
                  ),
                ),

                const SizedBox(height: 4),

                // ── Label ──
                Text(
                  widget.tab.label,
                  style: TextStyle(
                    fontFamily: 'Poppins Medium',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: selected
                        ? AppColors.primaryLight
                        : AppColors.grey,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
