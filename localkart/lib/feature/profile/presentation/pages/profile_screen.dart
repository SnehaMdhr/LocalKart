import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/app/theme/app_colors.dart';
import 'package:localkart/core/api/api_endpoints.dart';
import 'package:localkart/core/services/storage/user_session_service.dart';
import 'package:localkart/core/widgets/custom_button.dart';
import 'package:localkart/core/widgets/custom_icon_button.dart';
import 'package:localkart/core/widgets/custom_outlined_button.dart';
import 'package:localkart/feature/address/presentation/pages/address_screen.dart';
import 'package:localkart/feature/auth/presentation/pages/login_screen.dart';
import 'package:localkart/feature/collection/presentation/pages/collection_screen.dart';
import 'package:localkart/feature/order/presentation/pages/my_orders_screen.dart';
import 'package:localkart/feature/auth/presentation/view_model/auth_view_model.dart';
import 'package:localkart/feature/profile/presentation/pages/change_password_screen.dart';
import 'package:localkart/feature/profile/presentation/pages/edit_profile_screen.dart';
import 'package:localkart/feature/profile/presentation/pages/faq_screen.dart';
import 'package:localkart/feature/profile/presentation/pages/help_center_screen.dart';
import 'package:localkart/feature/profile/presentation/pages/privacy_policy-screen.dart';
import 'package:localkart/feature/profile/presentation/pages/terms_and_conditions_screen.dart';
import 'package:localkart/feature/vendor_registeration/presentation/pages/register_shop_screen.dart';

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
      builder: (dialogContext) {
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
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: CustomButton(
                      text: "Logout",
                      borderRadius: 40,
                      backgroundColor: AppColors.primary,
                      onPressed: () async {
                        Navigator.pop(dialogContext);
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
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: CustomOutlinedButton(
                      text: "Cancel",
                      borderRadius: 40,
                      height: 58,
                      onPressed: () {
                        Navigator.pop(dialogContext);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final userSession = ref.read(userSessionServiceProvider);
    final user = authState.authEntity;

    final userName = user?.name ?? userSession.getCurrentUserName() ?? "Unknown User";
    final rawProfilePicture = user?.imageUrl ?? userSession.getCurrentUserProfilePicture() ?? "";
    final profilePicture = rawProfilePicture.isNotEmpty &&
            !rawProfilePicture.startsWith('http://') &&
            !rawProfilePicture.startsWith('https://')
        ? '${ApiEndpoints.mediaServerUrl}/${rawProfilePicture.startsWith('/') ? rawProfilePicture.substring(1) : rawProfilePicture}'
        : rawProfilePicture;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Stack(
              children: [
                profilePicture.isNotEmpty
                    ? ClipOval(
                        child: SizedBox(
                          width: 84,
                          height: 84,
                          child: Image.network(
                            profilePicture,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: AppColors.primary,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: AppColors.primary,
                                child: Center(
                                  child: Text(
                                    userName.isNotEmpty
                                        ? userName[0].toUpperCase()
                                        : "U",
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      )
                    : CircleAvatar(
                        radius: 42,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          userName.isNotEmpty
                              ? userName[0].toUpperCase()
                              : "U",
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              userName,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
        
            const SizedBox(height: 30),
            _profileTile(
              icon: Icons.person_outline,
              title: "Edit Profile",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EditProfileScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            _profileTile(
              icon: Icons.lock_outline_rounded,
              title: "Change Password",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ChangePasswordScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            _profileTile(
              icon: Icons.location_on_outlined,
              title: "My Addresses",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddressScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            _profileTile(
              icon: Icons.receipt_long_outlined,
              title: "My Orders",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MyOrdersScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            _profileTile(
              icon: Icons.favorite_border,
              title: "Saved Items",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CollectionScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PrivacyPolicyScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            _profileTile(
              icon: Icons.gavel_outlined,
              title: "Terms of Service",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TermsAndConditionsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            _profileTile(
              icon: Icons.help_outline_outlined,
              title: "Help Center",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HelpCenterScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            _profileTile(
              icon: Icons.fax_outlined,
              title: "Frequently Asked Questions",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FaqScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 35),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: CustomButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RegisterShopScreen(),
                    ),
                  );
                },
                text: 'Register Your Store',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: CustomIconButton(
                text: "Logout",
                icon: Icons.logout,
                onPressed: _showLogoutDialog,
                backgroundColor: AppColors.logoutBackground,
                foregroundColor: AppColors.logoutText,
              ),
            ),
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