import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../utils/responsive.dart';

/// Layout standar Figma: background #FDFCFF, konten mobile-width, rata atas.
class FigmaPageBody extends StatelessWidget {
  const FigmaPageBody({
    super.key,
    required this.child,
    this.padding,
    this.scrollable = true,
    this.hasBottomNavBar = false,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool scrollable;
  final bool hasBottomNavBar;

  @override
  Widget build(BuildContext context) {
    EdgeInsetsGeometry resolvedPadding =
        padding ?? Responsive.pagePadding(context);

    if (hasBottomNavBar) {
      resolvedPadding = resolvedPadding.add(const EdgeInsets.only(bottom: 100));
    }

    final Widget content = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: Responsive.contentWidth(context)),
      child: scrollable
          ? SingleChildScrollView(
              padding: resolvedPadding,
              child: child,
            )
          : Padding(
              padding: resolvedPadding,
              child: child,
            ),
    );

    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: content,
        ),
      ),
    );
  }
}
