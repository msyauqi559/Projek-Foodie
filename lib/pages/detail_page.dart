import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../constants/app_colors.dart';
import '../models/food_item.dart';
import '../services/app_navigation.dart';
import '../services/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
                        Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              height: Responsive.value(
                                context,
                                mobile: 340,
                                tablet: 400,
                              ),
                              color: AppColors.background,
                              alignment: Alignment.center,
                              child: ReusableImage(
                                imagePath: detailImagePath,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.contain,
                                heroTag: food.id,
                                borderRadius: 0,
                              ),
                            ),
                            Positioned(
                              top: 16,
                              left: 20,
                              child: BackCircleButton(
                                onTap: () => AppNavigation.back(context),
                              ),
                            ),
                          ],
                        ),
                        Transform.translate(
                          offset: const Offset(0, -18),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 20,
                                  offset: const Offset(0, -6),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        food.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium
                                            ?.copyWith(
                                              fontSize: 24,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.textPrimary,
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
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.primary,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    // Rating pill
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFF7ED),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                            color: const Color(0xFFFFEDD5)),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.star_rounded,
                                            color: Color(0xFFF97316),
                                            size: 18,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            food.rating.toStringAsFixed(1),
                                            style: const TextStyle(
                                              color: Color(0xFFC2410C),
                                              fontWeight: FontWeight.w700,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    // Location pill
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: AppColors.background,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                              color: AppColors.borderLight),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.location_on_rounded,
                                              color: AppColors.primary,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                food.address,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: AppColors.textPrimary,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                const Divider(
                                  color: AppColors.borderLight,
                                  height: 1,
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'Deskripsi',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                      ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  food.description,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        fontSize: 14,
                                        height: 1.6,
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                                 const SizedBox(height: 24),
                                 // ── Menampilkan Tags Makanan secara dinamis jika tersedia ──
                                 if (food.tags.isNotEmpty) ...[
                                   Text(
                                     'Tags Makanan',
                                     style: Theme.of(context)
                                         .textTheme
                                         .titleMedium
                                         ?.copyWith(
                                           fontSize: 16,
                                           fontWeight: FontWeight.w800,
                                           color: AppColors.textPrimary,
                                         ),
                                   ),
                                   const SizedBox(height: 12),
                                   // Wrap otomatis merapikan posisi chip ke baris berikutnya jika melebihi lebar layar
                                   Wrap(
                                     spacing: 8,
                                     runSpacing: 8,
                                     children: food.tags.map((tag) {
                                       return Container(
                                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                         decoration: BoxDecoration(
                                           color: AppColors.primary.withValues(alpha: 0.08),
                                           borderRadius: BorderRadius.circular(20),
                                           border: Border.all(
                                             color: AppColors.primary.withValues(alpha: 0.15),
                                             width: 1,
                                           ),
                                         ),
                                         child: Text(
                                           '#$tag',
                                           style: const TextStyle(
                                             color: AppColors.primary,
                                             fontWeight: FontWeight.bold,
                                             fontSize: 12,
                                           ),
                                         ),
                                       );
                                     }).toList(),
                                   ),
                                 ],
                                 const SizedBox(height: 40),
                                Center(
                                  child: FractionallySizedBox(
                                    widthFactor: 1.0,
                                    child: ReusableButton(
                                      label: 'Masukkan ke keranjang!',
                                      onPressed: () async {
                                        final prefs = await SharedPreferences.getInstance();
                                        final userId = prefs.getInt('user_id') ?? 2;
                                        int? targetMenuDbId = food.dbId;
                                        if (targetMenuDbId == null) {
                                          final allMenus = await DatabaseHelper.instance.getAllMenus();
                                          final match = allMenus.where((m) => m.name == food.name).firstOrNull;
                                          if (match != null) {
                                            targetMenuDbId = match.dbId;
                                          } else {
                                            targetMenuDbId = await DatabaseHelper.instance.insertMenu(food);
                                          }
                                        }
                                        if (targetMenuDbId != null) {
                                          await DatabaseHelper.instance.addToCart(userId, targetMenuDbId, 1);
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Berhasil dimasukkan ke keranjang!'),
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                            AppNavigation.openCart(context);
                                          }
                                        }
                                      },
                                      borderRadius: 16,
                                      height: 54,
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
