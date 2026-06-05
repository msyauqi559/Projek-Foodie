import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../models/order_history_item.dart';
import '../services/app_navigation.dart';
import '../services/dummy_data_service.dart';
import '../utils/formatters.dart';
import '../utils/responsive.dart';
import '../widgets/back_circle_button.dart';
import '../widgets/reusable_image.dart';

class OrderTrackingPage extends StatelessWidget {
  const OrderTrackingPage({
    super.key,
    this.showBackButton = true,
  });

  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    final order = DummyDataService.orderHistory.first;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: Responsive.contentWidth(context),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double width = constraints.maxWidth;
                final double locationPinLeft = width * 0.08;
                final double destinationLeft = width * 0.16;
                final double etaLeft = width * 0.22;
                final double destinationRight = width * 0.07;

                return Stack(
                  children: [
                const Positioned.fill(
                  child: ReusableImage(
                    imagePath: AppAssets.mapRoute,
                    fit: BoxFit.cover,
                    borderRadius: 0,
                  ),
                ),
                Positioned(
                  top: 12,
                  left: AppDimensions.screenHorizontal,
                  right: AppDimensions.screenHorizontal,
                  child: showBackButton
                      ? Align(
                          alignment: Alignment.centerLeft,
                          child: BackCircleButton(
                            onTap: () => AppNavigation.back(context),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                Positioned(
                  left: locationPinLeft,
                  top: 100,
                  child: const Icon(
                    Icons.location_on,
                    color: Color(0xFFE53935),
                    size: 34,
                  ),
                ),
                Positioned(
                  top: 92,
                  left: destinationLeft,
                  right: destinationRight,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.dark, width: 2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Jalan Imam Bonjol No.19',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 195,
                  left: etaLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.dark, width: 1),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1A000000),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.pedal_bike_rounded, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              '9 mnt',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: AppColors.primary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ),
                        Text(
                          '4,1 km',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.grayText,
                                fontSize: 13,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(
                      14,
                      14,
                      14,
                      12 + MediaQuery.paddingOf(context).bottom,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.route_rounded,
                              size: 18,
                              color: AppColors.card,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Perjalanan menuju rumah anda!',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: AppColors.card,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const ReusableImage(
                                    imagePath: AppAssets.courier,
                                    width: 84,
                                    height: 84,
                                    borderRadius: 18,
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Ahmad Jokowidodo',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                        const SizedBox(height: 10),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFD7FFD9),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.location_on_rounded,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Dalam perjalanan',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(fontSize: 13),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Divider(
                                color: Color(0xFF7B7B7B),
                                height: 1,
                              ),
                              const SizedBox(height: 12),
                              _TrackingSummary(order: order),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _TrackingSummary extends StatelessWidget {
  const _TrackingSummary({required this.order});

  final OrderHistoryItem order;

  @override
  Widget build(BuildContext context) {
    final double subtotal = order.food.price * order.quantity;
    final int taxPercentage = subtotal <= 0
        ? 0
        : ((order.tax / subtotal) * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ringkasan pembayaran',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),
        _TrackingSummaryRow(
          label: 'Jumlah tagihan',
          value: '${PriceFormatter.toRupiah(subtotal)} (${order.quantity}x)',
        ),
        _TrackingSummaryRow(
          label: 'Kode promo',
          value: '-${PriceFormatter.toRupiah(order.promoDiscount)}',
        ),
        _TrackingSummaryRow(
          label: 'Pengiriman',
          value: PriceFormatter.toRupiah(order.shippingCost),
        ),
        _TrackingSummaryRow(
          label: 'Pajak',
          value: '${PriceFormatter.toRupiah(order.tax)} ($taxPercentage%)',
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Divider(color: AppColors.grayText, height: 1),
        ),
        _TrackingSummaryRow(
          label: 'Total Pembayaran',
          value: PriceFormatter.toRupiah(order.total),
          isBold: true,
        ),
      ],
    );
  }
}

class _TrackingSummaryRow extends StatelessWidget {
  const _TrackingSummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  final String label;
  final String value;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: isBold ? AppColors.textPrimary : AppColors.grayText,
          fontSize: isBold ? 16 : 15,
          fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
        );

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: style),
          ),
          Expanded(
            flex: 1,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: style,
            ),
          ),
        ],
      ),
    );
  }
}
