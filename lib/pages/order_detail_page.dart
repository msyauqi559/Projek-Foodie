import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../models/order_history_item.dart';
import '../services/app_navigation.dart';
import '../widgets/figma_page_body.dart';
import '../widgets/food_checkout_card.dart';
import '../widgets/order_summary_card.dart';
import '../widgets/page_header.dart';

class OrderDetailPage extends StatelessWidget {
  const OrderDetailPage({super.key, required this.order});

  final OrderHistoryItem order;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FigmaPageBody(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.screenHorizontal,
          12,
          AppDimensions.screenHorizontal,
          24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: 'Detail',
              onBack: () => AppNavigation.back(context),
            ),
            const SizedBox(height: AppDimensions.headerBottomGap),
            FoodCheckoutCard(
              food: order.food,
              priceColor: AppColors.primaryDark,
            ),
            const SizedBox(height: AppDimensions.sectionGap),
            OrderSummaryCard(
              order: order,
              showPromoCode: true,
              totalLabel: 'Total yang sudah dibayar',
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: order.statusLabel == 'Berhasil' ? AppColors.primary : Colors.grey.shade400,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: order.statusLabel == 'Berhasil'
                    ? () => AppNavigation.openTracking(context, order)
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Status saat ini: ${order.statusLabel}. Hubungi admin untuk konfirmasi pembayaran.',
                            ),
                          ),
                        );
                      },
                child: Text(
                  order.statusLabel == 'Berhasil' ? 'Lacak Pesanan Anda' : 'Menunggu Konfirmasi Admin',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
