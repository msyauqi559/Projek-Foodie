import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
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
    final Color statusColor;
    final Color statusBgColor;
    final IconData statusIcon;

    if (order.statusLabel == 'Berhasil') {
      statusColor = AppColors.success;
      statusBgColor = AppColors.success.withValues(alpha: 0.1);
      statusIcon = Icons.check_circle_rounded;
    } else if (order.statusLabel == 'Belum Membayar') {
      statusColor = AppColors.warning;
      statusBgColor = AppColors.warning.withValues(alpha: 0.1);
      statusIcon = Icons.pending_actions_rounded;
    } else {
      statusColor = AppColors.danger;
      statusBgColor = AppColors.danger.withValues(alpha: 0.1);
      statusIcon = Icons.cancel_rounded;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.8)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ReusableImage(
                    imagePath: order.food.imagePath,
                    width: 80,
                    height: 80,
                    borderRadius: 14,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                order.food.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusBgColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    statusIcon,
                                    color: statusColor,
                                    size: 11,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    order.statusLabel,
                                    style: TextStyle(
                                      color: statusColor,
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                order.food.address,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 10.5,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          order.dateLabel,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 10.5,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(color: AppColors.borderLight, height: 24, thickness: 1),
              Row(
                children: [
                  Text(
                    '${order.quantity} Item',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const Spacer(),
                  Text(
                    'Total Pembayaran',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    PriceFormatter.toRupiah(order.total),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
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
