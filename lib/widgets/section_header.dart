import 'package:flutter/material.dart';

// import '../constants/app_colors.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.fontSize = 16,
  });

  final String title;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontSize: fontSize),
        ),
        const SizedBox(height: 4),
        // LayoutBuilder(
        //   builder: (context, constraints) {
        //     final double lineWidth = constraints.maxWidth < 190
        //         ? constraints.maxWidth
        //         : 190;

        //     return SizedBox(
        //       width: lineWidth,
        //       height: 8,
        //       child: Stack(
        //         alignment: Alignment.centerLeft,
        //         children: [
        //           Container(
        //             width: lineWidth,
        //             height: 1,
        //             color: AppColors.sectionLine,
        //           ),
        //           const Align(
        //             alignment: Alignment.centerRight,
        //             child: Icon(
        //               Icons.circle,
        //               size: 6,
        //               color: AppColors.grayMuted,
        //             ),
        //           ),
        //         ],
        //       ),
        //     );
        //   },
        // ),
      ],
    );
  }
}
