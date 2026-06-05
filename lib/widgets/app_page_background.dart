import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Memastikan area scroll tab shell memakai latar #FDFCFF penuh.
class AppPageBackground extends StatelessWidget {
  const AppPageBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: child,
    );
  }
}
