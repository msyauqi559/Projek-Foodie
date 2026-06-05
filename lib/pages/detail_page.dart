import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../models/food_item.dart';
import '../services/app_navigation.dart';
import '../utils/formatters.dart';
import '../utils/responsive.dart';
import '../widgets/back_circle_button.dart';
import '../widgets/reusable_button.dart';
import '../widgets/reusable_image.dart';

class DetailPage extends StatelessWidget {
  const DetailPage({super.key, required this.food});

  final FoodItem food;

  @override
  Widget build(BuildContext context) {
    final String detailImagePath =
        food.id == 'mie-ayam' ? AppAssets.mieAyamCutout : food.imagePath;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: Responsive.contentWidth(context),
            ),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                          child: BackCircleButton(
                            onTap: () => AppNavigation.back(context),
                          ),
                        ),
                        ReusableImage(
                          imagePath: detailImagePath,
                          width: double.infinity,
                          height: Responsive.value(
                            context,
                            mobile: 360,
                            tablet: 420,
                          ),
                          fit: BoxFit.contain,
                          heroTag: food.id,
                          borderRadius: 0,
                        ),
                        Transform.translate(
                          offset: const Offset(0, -18),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
                            decoration: const BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(26),
                                topRight: Radius.circular(26),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.shadow,
                                  blurRadius: 18,
                                  offset: Offset(0, -2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        food.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium
                                            ?.copyWith(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      PriceFormatter.toRupiah(food.price),
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.copyWith(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                const Divider(
                                  color: AppColors.divider,
                                  height: 1,
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      color: AppColors.warning,
                                      size: 28,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      food.rating.toStringAsFixed(1),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(top: 2),
                                      child: Icon(
                                        Icons.location_on_outlined,
                                        size: 20,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        food.address,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                const Divider(
                                  color: AppColors.divider,
                                  height: 1,
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  'Deskripsi',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  food.description,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        fontSize: 15,
                                        height: 1.6,
                                        color: AppColors.textPrimary,
                                      ),
                                ),
                                const SizedBox(height: 64),
                                Center(
                                  child: FractionallySizedBox(
                                    widthFactor: 0.9,
                                    child: ReusableButton(
                                      label: 'Masukkan ke keranjang!',
                                      onPressed: () =>
                                          AppNavigation.openCart(context, food),
                                      borderRadius: AppDimensions.radiusMd,
                                      height: 60,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
