import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../models/order_history_item.dart';
import '../utils/formatters.dart';

class OrderSummaryCard extends StatelessWidget {
  const OrderSummaryCard({
    super.key,
    required this.order,
    this.showPromoCode = false,
    this.totalLabel = 'Total Pembayaran',
  });

  final OrderHistoryItem order;
  final bool showPromoCode;
  final String totalLabel;

  @override
  Widget build(BuildContext context) {
    final double subtotal = order.food.price * order.quantity;
    final int taxPercentage = subtotal <= 0
        ? 0
        : ((order.tax / subtotal) * 100).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ringkasan pembayaran',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontSize: 16),
          ),
          const SizedBox(height: AppSpacing.md),
          _SummaryRow(
            label: 'Jumlah tagihan',
            value: '${PriceFormatter.toRupiah(subtotal)} (${order.quantity}x)',
          ),
          _SummaryRow(
            label: 'Kode promo',
            value: order.promoDiscount > 0
                ? '-${PriceFormatter.toRupiah(order.promoDiscount)}'
                : '-',
          ),
          _SummaryRow(
            label: 'Pengiriman',
            value: PriceFormatter.toRupiah(order.shippingCost),
          ),
          _SummaryRow(
            label: 'Pajak',
            value: '${PriceFormatter.toRupiah(order.tax)} ($taxPercentage%)',
          ),
          if (showPromoCode)
            _SummaryRow(
              label: 'Jenis Kode',
              value: order.promoCode,
            ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Divider(color: AppColors.grayText, height: 1),
          ),
          _SummaryRow(
            label: totalLabel,
            value: PriceFormatter.toRupiah(order.total),
            isBold: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  final String label;
  final String value;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: isBold ? AppColors.textPrimary : AppColors.grayText,
          fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
          fontSize: isBold ? 15 : 14,
        );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: textStyle),
          ),
          Expanded(
            flex: 1,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: textStyle,
            ),
          ),
        ],
      ),
    );
  }
}
