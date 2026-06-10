import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../constants/app_colors.dart';
import 'reusable_image.dart';

/// Header Home Figma: ikon + Foodie + tagline.
class HomeBrandHeader extends StatelessWidget {
  const HomeBrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const ReusableImage(
          imagePath: AppAssets.logo,
          width: 48,
          height: 48,
          fit: BoxFit.contain,
          borderRadius: 0,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Foodie',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      height: 1.1,
                    ),
              ),
              Text(
                'Pesan Cepat, Makan Enak',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
