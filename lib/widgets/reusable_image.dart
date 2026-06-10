import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';

class ReusableImage extends StatelessWidget {
  const ReusableImage({
    super.key,
    required this.imagePath,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.borderRadius = AppSpacing.radiusMd,
    this.heroTag,
    this.alignment = Alignment.center,
  });

  final String imagePath;
  final double? height;
  final double? width;
  final BoxFit fit;
  final double borderRadius;
  final String? heroTag;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final Widget content = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        color: borderRadius == 0 ? Colors.transparent : AppColors.muted,
        height: height,
        width: width,
        child: imagePath.startsWith('http')
            ? Image.network(
                imagePath,
                fit: fit,
                alignment: alignment,
                errorBuilder: (_, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.image_not_supported_rounded,
                      color: AppColors.textSecondary,
                    ),
                  );
                },
              )
            : Image.asset(
                imagePath,
                fit: fit,
                alignment: alignment,
                errorBuilder: (_, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.image_not_supported_rounded,
                      color: AppColors.textSecondary,
                    ),
                  );
                },
              ),
      ),
    );

    if (heroTag == null) {
      return content;
    }

    return Hero(tag: heroTag!, child: content);
  }
}
