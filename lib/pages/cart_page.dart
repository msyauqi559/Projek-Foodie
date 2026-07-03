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
import '../widgets/back_circle_button.dart';
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

  final TextEditingController _promoCTRL = TextEditingController();
  double appliedDiscount = 0.0;
  String appliedPromoCode = '';
  bool isPromoApplied = false;
  String correctPromoCode = '872008';
  double correctPromoDiscount = 2000.0;

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
    return _subtotal - appliedDiscount + _shippingCost + _tax;
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

    // Muat promo dari SharedPreferences
    correctPromoCode = prefs.getString('active_promo_code') ?? '872008';
    correctPromoDiscount = prefs.getDouble('active_promo_discount') ?? 2000.0;

    // maka insert item ini ke tb_cart terlebih dahulu Jika masuk ke CartPage dengan membawa widget.food,
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
      promoDiscount: appliedDiscount,
      shippingCost: _subtotal > 0 ? _shippingCost : 0,
      tax: _tax,
      promoCode: appliedPromoCode.isEmpty ? 'TIDAK ADA!' : appliedPromoCode,
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
            child: Stack(
              children: [
                Positioned.fill(
                  child: Column(
                    children: [
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
                                    const SizedBox(height: 5),
                                    Center(
                                      child: Text(
                                        'My Cart',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium
                                            ?.copyWith(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textPrimary,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    ListView.separated(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: cartItems.length,
                                      separatorBuilder: (context, index) =>
                                          const SizedBox(height: 16),
                                      itemBuilder: (context, index) {
                                        final item = cartItems[index];
                                        final FoodItem food = item['food'];
                                        final int qty = item['quantity'];
                                        final int cartId = item['id'];
                                        final bool isChecked =
                                            selectedCartItemIds.contains(
                                              cartId,
                                            );

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
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              onChanged: (val) {
                                                setState(() {
                                                  if (val == true) {
                                                    selectedCartItemIds.add(
                                                      cartId,
                                                    );
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
                                                      onTap: () => _updateQty(
                                                        cartId,
                                                        qty + 1,
                                                      ),
                                                      color: AppColors.primary,
                                                      iconColor: AppColors.card,
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      '$qty',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge
                                                          ?.copyWith(
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize: 14,
                                                            color: AppColors
                                                                .textPrimary,
                                                          ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    _CartQtyButton(
                                                      icon:
                                                          Icons.remove_rounded,
                                                      onTap: () => _updateQty(
                                                        cartId,
                                                        qty - 1,
                                                      ),
                                                      color:
                                                          AppColors.borderLight,
                                                      iconColor:
                                                          AppColors.grayText,
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
                                      height: 52,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.card,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: AppColors.borderLight,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.confirmation_num_outlined,
                                            color: AppColors.primary,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: TextField(
                                              controller: _promoCTRL,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.textPrimary,
                                              ),
                                              decoration: const InputDecoration(
                                                hintText: 'Masukkan Kode Promo',
                                                hintStyle: TextStyle(
                                                  color: AppColors.grayText,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                                border: InputBorder.none,
                                                isDense: true,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          SizedBox(
                                            height: 38,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                final codeInput = _promoCTRL
                                                    .text
                                                    .trim()
                                                    .toUpperCase();
                                                if (codeInput ==
                                                    correctPromoCode) {
                                                  setState(() {
                                                    appliedDiscount =
                                                        correctPromoDiscount;
                                                    appliedPromoCode =
                                                        codeInput;
                                                    isPromoApplied = true;
                                                  });
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'Kode Promo Berhasil diterapkan',
                                                      ),
                                                    ),
                                                  );
                                                } else {
                                                  setState(() {
                                                    appliedDiscount = 0.0;
                                                    appliedPromoCode = '';
                                                    isPromoApplied = false;
                                                  });
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'Kode Promo tidak valid!',
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: isPromoApplied
                                                    ? Colors.green
                                                    : AppColors.primary,
                                                foregroundColor: Colors.white,
                                                elevation: 0,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 15,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              child: Text(
                                                isPromoApplied
                                                    ? 'Terkonfirmasi'
                                                    : 'Gunakan',
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                ),
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
                                      if (selectedCartItemIds.contains(
                                        cartId,
                                      )) {
                                        final FoodItem food = item['food'];
                                        final int qty = item['quantity'];
                                        final double itemSubtotal =
                                            food.price * qty;
                                        final double itemTax =
                                            itemSubtotal * _taxRate;
                                        final double itemTotal =
                                            itemSubtotal -
                                            appliedDiscount +
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
                                          promoDiscount: appliedDiscount,
                                          shippingCost: _shippingCost,
                                          tax: itemTax,
                                          promoCode: appliedPromoCode.isEmpty
                                              ? 'TIDAK ADA'
                                              : appliedPromoCode,
                                        );
                                        await DatabaseHelper.instance
                                            .insertPesanan(finalOrder);
                                        await DatabaseHelper.instance
                                            .removeFromCart(cartId);
                                      }
                                    }

                                    if (context.mounted) {
                                      _showSuccessSheet(context, previewOrder);
                                    }
                                  },
                            borderRadius: 16,
                            height: 56,
                          ),
                        ),
                    ],
                  ),
                ),
                Positioned(
                  top: 16,
                  left: AppDimensions.screenHorizontal,
                  child: BackCircleButton(
                    onTap: () => AppNavigation.back(context),
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
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.screenHorizontal,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60),
          Text(
            'My Cart',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(
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
