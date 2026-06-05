import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../models/food_item.dart';
import '../utils/formatters.dart';
import 'reusable_image.dart';

/// Kartu item makanan di My Cart & Detail pembayaran (Figma).
class FoodCheckoutCard extends StatelessWidget {
  const FoodCheckoutCard({
    super.key,
    required this.food,
    this.priceColor,
    this.trailing,
  });

  final FoodItem food;
  final Color? priceColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReusableImage(
            imagePath: food.imagePath,
            width: 154,
            height: 96,
            borderRadius: AppDimensions.radiusMd,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.location_on_outlined,
                        size: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        food.address,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 10.5,
                              color: AppColors.textPrimary,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  PriceFormatter.toRupiah(food.price),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 16,
                        color: priceColor ?? AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
