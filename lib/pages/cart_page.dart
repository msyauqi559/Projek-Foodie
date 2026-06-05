import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_spacing.dart';
import '../models/food_item.dart';
import '../models/order_history_item.dart';
import '../services/app_navigation.dart';
import '../utils/responsive.dart';
import '../widgets/food_checkout_card.dart';
import '../widgets/order_summary_card.dart';
import '../widgets/page_header.dart';
import '../widgets/reusable_button.dart';
import '../services/database_helper.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key, required this.food});

  final FoodItem food;

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  int quantity = 1;

  static const double _promoDiscount = 2000;
  static const double _shippingCost = 5000;
  static const double _taxRate = 0.10;

  double get _subtotal => widget.food.price * quantity;
  double get _tax => _subtotal * _taxRate;
  double get _total => _subtotal - _promoDiscount + _shippingCost + _tax;

  @override
  Widget build(BuildContext context) {
    final OrderHistoryItem previewOrder = OrderHistoryItem(
      id: 'cart-preview',
      food: widget.food,
      quantity: quantity,
      dateLabel: 'Today',
      statusLabel: 'Berhasil',
      isSuccess: true,
      total: _total,
      promoDiscount: _promoDiscount,
      shippingCost: _shippingCost,
      tax: _tax,
      promoCode: '872008',
    );

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
                    padding: const EdgeInsets.fromLTRB(
                      AppDimensions.screenHorizontal,
                      12,
                      AppDimensions.screenHorizontal,
                      16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PageHeader(
                          title: 'My Cart',
                          onBack: () => AppNavigation.back(context),
                        ),
                        const SizedBox(height: AppDimensions.headerBottomGap),
                        FoodCheckoutCard(
                          food: widget.food,
                          priceColor: AppColors.primary,
                          trailing: Column(
                            children: [
                              _CartQtyButton(
                                icon: Icons.add_rounded,
                                onTap: () => setState(() => quantity++),
                                color: AppColors.primary,
                                iconColor: AppColors.card,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '$quantity',
                                style: Theme.of(
                                  context,
                                ).textTheme.titleMedium?.copyWith(fontSize: 16),
                              ),
                              const SizedBox(height: 6),
                              _CartQtyButton(
                                icon: Icons.remove_rounded,
                                onTap: quantity > 1
                                    ? () => setState(() => quantity--)
                                    : null,
                                color: AppColors.qtyInactive,
                                iconColor: AppColors.grayText,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Container(
                          height: 52,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(19),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  '872008',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontSize: 15),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(18.5),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Kode promo terkonfirmasi',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        color: AppColors.card,
                                        fontSize: 12,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        OrderSummaryCard(
                          order: previewOrder,
                          totalLabel: 'Total Pemabayaran',
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.screenHorizontal,
                    0,
                    AppDimensions.screenHorizontal,
                    16,
                  ),
                  child: ReusableButton(
                    label: 'Pesan Sekarang!',
                    onPressed: () async {
                      // Simpan ke SQLite
                      await DatabaseHelper.instance.insertPesanan(previewOrder);
                      // Tampilkan popup sukses
                      if (context.mounted) _showSuccessSheet(context);
                    },
                    borderRadius: AppDimensions.radiusMd,
                    height: 60,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showSuccessSheet(BuildContext parentContext) {
    return showModalBottomSheet<void>(
      context: parentContext,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 26, 24, 32),
          decoration: const BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(26),
              topRight: Radius.circular(26),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_outline_rounded,
                color: AppColors.success,
                size: 86,
              ),
              const SizedBox(height: 10),
              Text(
                'Pesanan berhasil!',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Text(
                'Kami menyiapkan pesanan anda\npantau pesanan anda',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(height: 1.5, fontSize: 14),
              ),
              const SizedBox(height: 26),
              ReusableButton(
                label: 'Halaman utama',
                onPressed: () {
                  Navigator.pop(context);
                  AppNavigation.finishCheckoutGoHome(parentContext);
                },
                borderRadius: AppDimensions.authButtonRadius,
              ),
              const SizedBox(height: 12),
              ReusableButton(
                label: 'Lacak pesanan anda',
                onPressed: () {
                  Navigator.pop(context);
                  AppNavigation.finishCheckoutGoTracking(parentContext);
                },
                borderRadius: AppDimensions.authButtonRadius,
                isPrimary: false,
                backgroundColor: AppColors.neutralButton,
                borderColor: AppColors.neutralButton,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CartQtyButton extends StatelessWidget {
  const _CartQtyButton({
    required this.icon,
    required this.onTap,
    required this.color,
    required this.iconColor,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final Color color;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: onTap != null ? color : AppColors.borderSubtle,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 18,
          color: onTap != null ? iconColor : AppColors.grayMuted,
        ),
      ),
    );
  }
}
