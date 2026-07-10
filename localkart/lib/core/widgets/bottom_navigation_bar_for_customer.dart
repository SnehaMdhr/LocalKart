import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/app/theme/app_colors.dart';
import 'package:localkart/core/widgets/title_app_bar.dart';
import 'package:localkart/feature/auth/presentation/pages/discover_screen.dart';
import 'package:localkart/feature/cart/presentation/pages/cart_screen.dart';
import 'package:localkart/feature/product/presentation/pages/home_screen.dart';
import 'package:localkart/feature/profile/presentation/pages/profile_screen.dart';

class BottomNavigationBarForCustomer extends ConsumerStatefulWidget {
  const BottomNavigationBarForCustomer({super.key});

  @override
  ConsumerState<BottomNavigationBarForCustomer> createState() =>
      _BottomNavigationBarForCustomerState();
}

class _BottomNavigationBarForCustomerState
    extends ConsumerState<BottomNavigationBarForCustomer> {
  int _selectedIndex = 0;

  final List<Widget> screens = const [
    HomeScreen(),
    DiscoverScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 18 : 10,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color:
                  isSelected ? Colors.white : AppColors.textSecondary,
              size: 24,
            ),

            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleAppBar(
        onNotificationTap: () {
          // TODO: Navigate to Notification Screen
        },
      ),

      body: screens[_selectedIndex],

      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_rounded,
                label: "Home",
                index: 0,
              ),
              _buildNavItem(
                icon: Icons.search_rounded,
                label: "Discover",
                index: 1,
              ),
              _buildNavItem(
                icon: Icons.shopping_cart_outlined,
                label: "Cart",
                index: 2,
              ),
              _buildNavItem(
                icon: Icons.person_outline_rounded,
                label: "Profile",
                index: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}