import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/app/theme/app_colors.dart';
import 'package:localkart/core/services/storage/user_session_service.dart';
import 'package:localkart/core/widgets/custom_button.dart';
import 'package:localkart/core/widgets/custom_icon_button.dart';
import 'package:localkart/core/widgets/custom_outlined_button.dart';
import 'package:localkart/feature/auth/presentation/pages/login_screen.dart';
import 'package:localkart/feature/auth/presentation/view_model/auth_view_model.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}


class _ProfileScreenState extends ConsumerState<ProfileScreen> {

  Future<void> _showLogoutDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 5,
            sigmaY: 5,
          ),
          child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Confirm Logout",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: AppColors.dialogTitle,
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  "Are you sure you want to logout?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 35),

                /// Logout Button
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: CustomButton(
                    text: "Logout",
                    borderRadius: 40,
                    backgroundColor: AppColors.primary,
                    onPressed: () async {
                      Navigator.pop(context);

                      await ref
                          .read(authViewModelProvider.notifier)
                          .logout();

                      if (!mounted) return;

                      await ref
                          .read(userSessionServiceProvider)
                          .clearSession();

                      if (mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                          (route) => false,
                        );
                      }
                    },
                  ),
                ),

                const SizedBox(height: 16),

                /// Cancel Button
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: CustomOutlinedButton(
                    text: "Cancel",
                    borderRadius: 40,
                    height: 58,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),);
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            const SizedBox(height: 10),

            /// Profile Image
            Stack(
              children: [
                const CircleAvatar(
                  radius: 42,
                  backgroundImage:
                      AssetImage('assets/images/profile.jpg'),
                ),

                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 14,
                      color: AppColors.card,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            const Text(
              "Arav Sharma",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              "+977 9841234567",
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 30),

            /// Address Card
            _profileTile(
              icon: Icons.location_on_outlined,
              title: "My Addresses",
              onTap: () {},
            ),

            const SizedBox(height: 10),

            /// Dark Mode Tile
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor:
                        AppColors.primary.withOpacity(0.08),
                    child: const Icon(
                      Icons.dark_mode_outlined,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(width: 14),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Dark Mode",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "Switch to a darker theme",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Switch(
                    value: false,
                    onChanged: (value) {},
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "ABOUT LOCALKART",
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),

            const SizedBox(height: 12),

            _profileTile(
              icon: Icons.shield_outlined,
              title: "Privacy Policy",
              onTap: () {},
            ),

            const SizedBox(height: 10),

            _profileTile(
              icon: Icons.gavel_outlined,
              title: "Terms of Service",
              onTap: () {},
            ),

            const SizedBox(height: 35),

            /// Register Store Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: CustomButton(
                onPressed: () {},
                text: 'Register Your Store',
              ),
            ),

            const SizedBox(height: 16),

            /// Logout Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: CustomIconButton(
                text: "Logout",
                icon: Icons.logout,
                onPressed: _showLogoutDialog,
                backgroundColor: AppColors.logoutBackground,
                foregroundColor: AppColors.logoutText,
              ),),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _profileTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor:
              AppColors.primary.withOpacity(0.08),
          child: Icon(
            icon,
            color: AppColors.primary,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}