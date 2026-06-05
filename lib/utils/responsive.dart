import 'package:flutter/material.dart';

class Responsive {
  const Responsive._();

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 768;

  static double value(
    BuildContext context, {
    required double mobile,
    required double tablet,
  }) {
    return isTablet(context) ? tablet : mobile;
  }

  static int gridCount(
    BuildContext context, {
    int mobile = 2,
    int tablet = 3,
  }) {
    return isTablet(context) ? tablet : mobile;
  }

  static double contentWidth(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    if (width >= 1024) {
      return 520;
    }
    if (isTablet(context)) {
      return 760;
    }
    return double.infinity;
  }

  static EdgeInsets pagePadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: value(context, mobile: 12, tablet: 16),
      vertical: value(context, mobile: 20, tablet: 24),
    );
  }
}
