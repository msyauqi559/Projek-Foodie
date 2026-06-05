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
          ],
        ),
      ),
    );
  }
}
