import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';

class ReusableButton extends StatelessWidget {
  const ReusableButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isPrimary = true,
    this.width = double.infinity,
    this.height = 56,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderRadius = AppSpacing.radiusMd,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isPrimary;
  final double width;
  final double height;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final Color resolvedBackgroundColor =
        backgroundColor ?? (isPrimary ? AppColors.primary : AppColors.card);
    final Color resolvedForegroundColor =
        foregroundColor ?? (isPrimary ? AppColors.card : AppColors.textPrimary);
    final BorderSide borderSide = BorderSide(
      color: borderColor ?? (isPrimary ? AppColors.primary : AppColors.line),
    );
    final bool isCompact = width.isFinite && width < 120;

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: resolvedBackgroundColor,
          foregroundColor: resolvedForegroundColor,
          elevation: isPrimary ? 0 : 0,
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? AppSpacing.xs : AppSpacing.lg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: borderSide,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              const SizedBox(width: AppSpacing.sm),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: resolvedForegroundColor,
                    fontSize: isCompact ? 12 : null,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
