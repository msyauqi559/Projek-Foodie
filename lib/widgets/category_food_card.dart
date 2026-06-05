import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/food_item.dart';
import '../utils/formatters.dart';
import 'reusable_image.dart';

class CategoryFoodCard extends StatelessWidget {
  const CategoryFoodCard({
    super.key,
    required this.food,
    required this.onTap,
  });

  final FoodItem food;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 140,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ReusableImage(
                imagePath: food.imagePath,
                width: double.infinity,
                height: 130,
                borderRadius: 12,
              ),
              const SizedBox(height: 8),
              Text(
                food.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                    ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      PriceFormatter.toRupiah(food.price),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                    ),
                  ),
                  const Icon(
                    Icons.star_rounded,
                    color: AppColors.warning,
                    size: 12,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    food.rating.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          color: AppColors.textPrimary,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
