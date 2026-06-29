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
          15,
          AppDimensions.screenHorizontal,
          85,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: 'Detail',
              onBack: () => AppNavigation.back(context),             
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: order.statusLabel == 'Berhasil'
                    ? Colors.green.shade50
                    : order.statusLabel == 'Belum Membayar'
                        ? Colors.orange.shade50
                        : Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: order.statusLabel == 'Berhasil'
                      ? Colors.green.shade200
                      : order.statusLabel == 'Belum Membayar'
                          ? Colors.orange.shade200
                          : Colors.red.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    order.statusLabel == 'Berhasil'
                        ? Icons.check_circle_rounded
                        : order.statusLabel == 'Belum Membayar'
                            ? Icons.access_time_filled_rounded
                            : Icons.cancel_rounded,
                    color: order.statusLabel == 'Berhasil'
                        ? Colors.green.shade700
                        : order.statusLabel == 'Belum Membayar'
                            ? Colors.orange.shade700
                            : Colors.red.shade700,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Status Pesanan',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          order.statusLabel,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: order.statusLabel == 'Berhasil'
                                ? Colors.green.shade800
                                : order.statusLabel == 'Belum Membayar'
                                    ? Colors.orange.shade800
                                    : Colors.red.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
                  backgroundColor: order.statusLabel == 'Berhasil'
                      ? AppColors.primary
                      : order.statusLabel == 'Belum Membayar'
                          ? Colors.grey.shade400
                          : AppColors.danger,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: order.statusLabel == 'Berhasil'
                    ? () => AppNavigation.openTracking(context, order)
                    : () {
                        final String message;
                        if (order.statusLabel == 'Belum Membayar') {
                          message = 'Harap tunggu konfirmasi dari Admin.';
                        } else {
                          message = 'Transaksi ini telah dinyatakan Gagal. Silakan melakukan pesanan ulang.';
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(message)),
                        );
                      },
                child: Text(
                  order.statusLabel == 'Berhasil'
                      ? 'Lacak Pesanan Anda'
                      : order.statusLabel == 'Belum Membayar'
                          ? 'Menunggu Konfirmasi Admin'
                          : 'Transaksi Gagal',
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
