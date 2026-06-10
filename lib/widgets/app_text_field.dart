import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.hintText,
    this.controller,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.obscureText = false,
    this.readOnly = false,
    this.onTap,
    this.borderRadius = AppSpacing.radiusMd,
    this.borderColor = AppColors.line,
    this.fillColor = AppColors.card,
    this.contentPadding,
    this.keyboardType,
    this.maxLines = 1,
  });

  final String hintText;
  final TextEditingController? controller;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final bool obscureText;
  final bool readOnly;
  final VoidCallback? onTap;
  final double borderRadius;
  final Color borderColor;
  final Color fillColor;
  final EdgeInsetsGeometry? contentPadding;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      readOnly: readOnly,
      onTap: onTap,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        prefixIcon: prefixIcon == null
            ? null
            : Icon(prefixIcon, color: AppColors.dark),
        suffixIcon: suffixIcon == null
            ? null
            : IconButton(
                onPressed: onSuffixTap,
                icon: Icon(suffixIcon, color: AppColors.dark),
              ),
        filled: true,
        fillColor: fillColor,
        contentPadding:
            contentPadding ??
            const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: borderColor,
            width: borderColor == AppColors.primary ? 1.2 : 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
        ),
      ),
    );
  }
}
