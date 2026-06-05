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
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final EdgeInsetsGeometry resolvedPadding =
        padding ?? Responsive.pagePadding(context);

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
