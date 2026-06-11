import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class CartButton extends StatelessWidget {
  const CartButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Material(
        color: AppColors.card,
        shape: const CircleBorder(
          side: BorderSide(color: AppColors.borderLight, width: 1.2),
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: const Padding(
            padding: EdgeInsets.all(10),
            child: Icon(
              Icons.shopping_bag_outlined,
              color: AppColors.textPrimary,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}
