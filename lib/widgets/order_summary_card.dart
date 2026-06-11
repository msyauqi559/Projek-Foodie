import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ringkasan pembayaran',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 18),
          _SummaryRow(
            label: 'Jumlah tagihan',
            value: '${PriceFormatter.toRupiah(subtotal)} (${order.quantity}x)',
          ),
          _SummaryRow(
            label: 'Kode promo',
            value: order.promoDiscount > 0
                ? '-${PriceFormatter.toRupiah(order.promoDiscount)}'
                : '-',
            valueColor: order.promoDiscount > 0 ? const Color(0xFF16A34A) : null,
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
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(color: AppColors.borderLight, height: 1),
          ),
          _SummaryRow(
            label: totalLabel,
            value: PriceFormatter.toRupiah(order.total),
            isBold: true,
            valueColor: AppColors.primary,
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
    this.valueColor,
  });

  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: isBold ? AppColors.textPrimary : AppColors.grayText,
          fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
          fontSize: isBold ? 15 : 13.5,
        );

    final valueStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: valueColor ?? (isBold ? AppColors.textPrimary : AppColors.textPrimary),
          fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
          fontSize: isBold ? 16 : 13.5,
        );

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: labelStyle),
          Text(
            value,
            textAlign: TextAlign.right,
            style: valueStyle,
          ),
        ],
      ),
    );
  }
}
