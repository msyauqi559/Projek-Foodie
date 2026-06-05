import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_spacing.dart';
import '../models/order_history_item.dart';
import '../services/app_navigation.dart';
import '../services/dummy_data_service.dart';
import '../widgets/app_text_field.dart';
import '../widgets/figma_page_body.dart';
import '../widgets/history_order_card.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<OrderHistoryItem> orders = DummyDataService.orderHistory;

    return FigmaPageBody(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Text(
              'History',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const AppTextField(
            hintText: 'Cari menu....',
            prefixIcon: Icons.search_rounded,
            borderColor: AppColors.primary,
            borderRadius: AppDimensions.tabSearchRadius,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 16,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ...orders.map(
            (order) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: HistoryOrderCard(
                order: order,
                onTap: () => AppNavigation.openOrderDetail(context, order),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
