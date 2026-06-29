import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
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
  const CartPage({super.key, this.food});
  final FoodItem? food;
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Map<String, dynamic>> cartItems = [];
  Set<int> selectedCartItemIds = {};
  bool isLoading = true;
  int? loggedInUserId;

  static const double _promoDiscount = 2000;
  static const double _shippingCost = 5000;
  static const double _taxRate = 0.10;

  double get _subtotal {
    double sum = 0;
    for (final item in cartItems) {
      if (selectedCartItemIds.contains(item['id'])) {
        final FoodItem food = item['food'];
        final int qty = item['quantity'];
        sum += food.price * qty;
      }
    }
    return sum;
  }

  double get _tax => _subtotal * _taxRate;

  double get _total {
    if (_subtotal == 0) return 0;
    return _subtotal - _promoDiscount + _shippingCost + _tax;
  }

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id') ?? 2;
    loggedInUserId = userId;

    // Jika masuk ke CartPage dengan membawa widget.food,
    // maka insert item ini ke tb_cart terlebih dahulu
    if (widget.food != null) {
      int? menuDbId = widget.food!.dbId;
      if (menuDbId == null) {
        // Cari menu di DB berdasarkan nama
        final allMenus = await DatabaseHelper.instance.getAllMenus();
        final match = allMenus
            .where((m) => m.name == widget.food!.name)
            .firstOrNull;
        if (match != null) {
          menuDbId = match.dbId;
        } else {
          menuDbId = await DatabaseHelper.instance.insertMenu(widget.food!);
        }
      }
      if (menuDbId != null) {
        await DatabaseHelper.instance.addToCart(userId, menuDbId, 1);
      }
    }

    // Load semua item dari tb_cart
    final dbItems = await DatabaseHelper.instance.getCartItems(userId);
    setState(() {
      cartItems = dbItems;
      // Otomatis centang/pilih semua item di awal
      selectedCartItemIds = dbItems.map((item) => item['id'] as int).toSet();
      isLoading = false;
    });
  }

  Future<void> _updateQty(int cartId, int newQty) async {
    if (newQty <= 0) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Hapus Item'),
          content: const Text(
            'Apakah Anda ingin menghapus item ini dari keranjang?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
      if (confirm == true) {
        await DatabaseHelper.instance.removeFromCart(cartId);
        _loadCart();
      }
    } else {
      await DatabaseHelper.instance.updateCartQuantity(cartId, newQty);
      setState(() {
        final idx = cartItems.indexWhere((item) => item['id'] == cartId);
        if (idx != -1) {
          cartItems[idx]['quantity'] = newQty;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final int selectedQuantitySum = cartItems
        .where((item) => selectedCartItemIds.contains(item['id']))
        .fold<int>(0, (sum, item) => sum + (item['quantity'] as int));

    final double mockPrice = selectedQuantitySum > 0
        ? _subtotal / selectedQuantitySum
        : 0;

    final FoodItem mockFood = FoodItem(
      id: 'cart-preview',
      name: 'Item Pilihan',
      category: '',
      address: '',
      description: '',
      imagePath: '',
      price: mockPrice,
      rating: 0,
      deliveryTime: '',
      distance: '',
      calories: 0,
      tags: [],
    );

    final OrderHistoryItem previewOrder = OrderHistoryItem(
      id: 'cart-preview',
      food: mockFood,
      quantity: selectedQuantitySum,
      userId: loggedInUserId ?? 2,
      dateLabel: () {
        final now = DateTime.now();
        final months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'Mei',
          'Jun',
          'Jul',
          'Agu',
          'Sep',
          'Okt',
          'Nov',
          'Des',
        ];
        return '${now.day} ${months[now.month - 1]} ${now.year}, ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      }(),
      statusLabel: 'Belum Membayar',
      isSuccess: false,
      total: _total,
      promoDiscount: _subtotal > 0 ? _promoDiscount : 0,
      shippingCost: _subtotal > 0 ? _shippingCost : 0,
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.screenHorizontal,
                    16,
                    AppDimensions.screenHorizontal,
                    0,
                  ),
                  child: PageHeader(
                    title: 'My Cart',
                    onBack: () => AppNavigation.back(context),
                  ),
                ),
                Expanded(
                  child: cartItems.isEmpty
                      ? _buildEmptyState()
                      : SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(
                            AppDimensions.screenHorizontal,
                            16,
                            AppDimensions.screenHorizontal,
                            20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: cartItems.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 16),
                                itemBuilder: (context, index) {
                                  final item = cartItems[index];
                                  final FoodItem food = item['food'];
                                  final int qty = item['quantity'];
                                  final int cartId = item['id'];
                                  final bool isChecked = selectedCartItemIds
                                      .contains(cartId);

                                  return Row(
                                    children: [
                                      Checkbox(
                                        value: isChecked,
                                        activeColor: AppColors.primary,
                                        checkColor: AppColors.card,
                                        side: const BorderSide(
                                          color: AppColors.grayText,
                                          width: 1.5,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                        ),
                                        onChanged: (val) {
                                          setState(() {
                                            if (val == true) {
                                              selectedCartItemIds.add(cartId);
                                            } else {
                                              selectedCartItemIds.remove(
                                                cartId,
                                              );
                                            }
                                          });
                                        },
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: FoodCheckoutCard(
                                          food: food,
                                          priceColor: AppColors.primary,
                                          trailing: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              _CartQtyButton(
                                                icon: Icons.add_rounded,
                                                onTap: () =>
                                                    _updateQty(cartId, qty + 1),
                                                color: AppColors.primary,
                                                iconColor: AppColors.card,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                '$qty',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color:
                                                          AppColors.textPrimary,
                                                    ),
                                              ),
                                              const SizedBox(height: 8),
                                              _CartQtyButton(
                                                icon: Icons.remove_rounded,
                                                onTap: () =>
                                                    _updateQty(cartId, qty - 1),
                                                color: AppColors.borderLight,
                                                iconColor: AppColors.grayText,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 24),
                              Container(
                                height: 54,
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: AppColors.card,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppColors.borderLight,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const SizedBox(width: 14),
                                    const Icon(
                                      Icons.local_offer_rounded,
                                      color: AppColors.primary,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '872008',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textPrimary,
                                            ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFF7ED),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(0xFFFFEDD5),
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Promo terkonfirmasi',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              color: const Color(0xFFC2410C),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              OrderSummaryCard(
                                order: previewOrder,
                                totalLabel: 'Total Pembayaran',
                              ),
                            ],
                          ),
                        ),
                ),
                if (cartItems.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimensions.screenHorizontal,
                      0,
                      AppDimensions.screenHorizontal,
                      16,
                    ),
                    child: ReusableButton(
                      label: 'Pesan Sekarang!',
                      onPressed: selectedCartItemIds.isEmpty
                          ? () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Pilih minimal satu item untuk dipesan!',
                                  ),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          : () async {
                              final DateTime now = DateTime.now();
                              final months = [
                                'Jan',
                                'Feb',
                                'Mar',
                                'Apr',
                                'Mei',
                                'Jun',
                                'Jul',
                                'Agu',
                                'Sep',
                                'Okt',
                                'Nov',
                                'Des',
                              ];
                              final String orderTimeLabel =
                                  '${now.day} ${months[now.month - 1]} ${now.year}, ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

                              for (final item in cartItems) {
                                final int cartId = item['id'];
                                if (selectedCartItemIds.contains(cartId)) {
                                  final FoodItem food = item['food'];
                                  final int qty = item['quantity'];
                                  final double itemSubtotal = food.price * qty;
                                  final double itemTax =
                                      itemSubtotal * _taxRate;
                                  final double itemTotal =
                                      itemSubtotal -
                                      _promoDiscount +
                                      _shippingCost +
                                      itemTax;

                                  final finalOrder = OrderHistoryItem(
                                    id: 'order-$cartId-${now.millisecondsSinceEpoch}',
                                    food: food,
                                    quantity: qty,
                                    userId: loggedInUserId ?? 2,
                                    dateLabel: orderTimeLabel,
                                    statusLabel: 'Belum Membayar',
                                    isSuccess: false,
                                    total: itemTotal,
                                    promoDiscount: _promoDiscount,
                                    shippingCost: _shippingCost,
                                    tax: itemTax,
                                    promoCode: '872008',
                                  );

                                  await DatabaseHelper.instance.insertPesanan(
                                    finalOrder,
                                  );
                                  await DatabaseHelper.instance.removeFromCart(
                                    cartId,
                                  );
                                }
                              }

                              if (context.mounted)
                                _showSuccessSheet(context, previewOrder);
                            },
                      borderRadius: 16,
                      height: 56,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF97316).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              color: AppColors.primary,
              size: 80,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Keranjang Belanja Kosong',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            'Wah, keranjang belanjaanmu masih kosong nih.\nYuk cari makanan lezat sekarang!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.5,
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 200,
            child: ReusableButton(
              label: 'Belanja Sekarang',
              onPressed: () {
                AppNavigation.finishCheckoutGoHome(context);
              },
              borderRadius: 14,
              height: 48,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showSuccessSheet(
    BuildContext parentContext,
    OrderHistoryItem previewOrder,
  ) {
    return showModalBottomSheet<void>(
      context: parentContext,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          decoration: const BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              const Icon(
                Icons.check_circle_outline_rounded,
                color: AppColors.success,
                size: 80,
              ),
              const SizedBox(height: 16),
              Text(
                'Pesanan berhasil!',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Kami menyiapkan pesanan anda\npantau pesanan anda',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.5,
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 28),
              ReusableButton(
                label: 'Halaman utama',
                onPressed: () {
                  Navigator.pop(context);
                  AppNavigation.finishCheckoutGoHome(parentContext);
                },
                borderRadius: 14,
                height: 48,
              ),
              const SizedBox(height: 12),
              ReusableButton(
                label: 'Menunggu Konfirmasi Admin...',
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    const SnackBar(
                      content: Text('Tunggu notifikasi dari admin'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                  AppNavigation.finishCheckoutGoHistory(parentContext);
                },
                borderRadius: 14,
                height: 48,
                isPrimary: false,
                backgroundColor: AppColors.borderLight,
                borderColor: AppColors.borderLight,
                foregroundColor: AppColors.textSecondary,
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
    final bool isEnabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isEnabled ? color : AppColors.borderLight,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 18,
          color: isEnabled ? iconColor : AppColors.grayText,
        ),
      ),
    );
  }
}
