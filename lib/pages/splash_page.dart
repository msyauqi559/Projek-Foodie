import 'dart:async';

import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../constants/app_colors.dart';
import '../services/app_navigation.dart';
import '../widgets/reusable_image.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      if (!mounted) {
        return;
      }

      AppNavigation.finishSplash(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: const Center(
        child: ReusableImage(
          imagePath: AppAssets.splashLogo,
          width: 280,
          height: 280,
          fit: BoxFit.contain,
          borderRadius: 0,
        ),
      ),
    );
  }
}
