import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
class NotificationButton extends StatelessWidget {
  const NotificationButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Material(
        color: AppColors.card,
        shape: const CircleBorder(
          side: BorderSide(color: AppColors.dark, width: 1),
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: const Padding(
            padding: EdgeInsets.all(10),
            child: Icon(
              Icons.notifications_none_rounded,
              color: AppColors.textPrimary,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}
