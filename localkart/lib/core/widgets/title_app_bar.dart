import 'package:flutter/material.dart';
import 'package:localkart/app/theme/app_colors.dart';

class TitleAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final VoidCallback? onNotificationTap;

  const TitleAppBar({
    super.key,
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
                color: Color(0xFF0F3D1F),
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

      /// Notification Icon
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                onPressed: onNotificationTap,
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.black87,
                  size: 30,
                ),
              ),

              /// Red Dot
              Positioned(
                top: 14,
                right: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}