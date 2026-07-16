import 'package:flutter/material.dart';
import 'package:localkart/app/theme/app_colors.dart';
import 'package:localkart/feature/notification/presentation/widgets/notification_bell.dart';

class TitleAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final bool showNotificationBell;
  final VoidCallback? onNotificationTap;

  const TitleAppBar({
    super.key,
    this.showNotificationBell = true,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,

      /// Left Logo
      leadingWidth: 80,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Center(
          child: Image.asset(
            "assets/images/logo1.png",
            height: 45,
          ),
        ),
      ),

      /// Middle Title
      title: RichText(
        text: const TextSpan(
          children: [
            TextSpan(
              text: "Local",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: "Kart",
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),

      /// Notification Bell with Badge
      actions: [
        if (showNotificationBell)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: NotificationBell(),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}