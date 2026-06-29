import 'package:flutter/material.dart';
import 'package:foodie_1/widgets/back_circle_button.dart';

import '../constants/app_colors.dart';

/// Header Figma: tombol back kiri + judul tengah 22px.
class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    this.onBack,
  });

  final String title;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (onBack != null)
            Align(
              alignment: Alignment.centerLeft,
              child: BackCircleButton(
                onTap: onBack,
              ),
            ),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
          ),
        ],
      ),
    );
  }
}
