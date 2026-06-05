import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../models/order_history_item.dart';
import '../utils/formatters.dart';
import 'reusable_image.dart';

class HistoryOrderCard extends StatelessWidget {
  const HistoryOrderCard({
    super.key,
    required this.order,
    required this.onTap,
  });

  final OrderHistoryItem order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color statusColor =
        order.isSuccess ? AppColors.historySuccess : AppColors.danger;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 18,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ReusableImage(
                    imagePath: order.food.imagePath,
                    width: 86,
                    height: 74,
                    borderRadius: 12,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.food.name,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontSize: 15,
                                  ),
                        ),
                        const SizedBox(height: 6),
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
                                order.food.address,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppColors.textPrimary,
                                      fontSize: 11,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          order.dateLabel,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textPrimary,
                                    fontSize: 12,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      order.isSuccess
                          ? Icons.check_rounded
                          : Icons.close_rounded,
                      color: order.isSuccess ? AppColors.dark : AppColors.card,
                      size: 28,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Text(
                    '${order.quantity} Item',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontSize: 12,
                        ),
                  ),
                  const Spacer(),
                  Text(
                    order.statusLabel,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: statusColor,
                          fontSize: 13,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Total Pembayaran',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 14,
                        ),
                  ),
                  const Spacer(),
                  Text(
                    PriceFormatter.toRupiah(order.total),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: statusColor,
                          fontSize: 14,
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
