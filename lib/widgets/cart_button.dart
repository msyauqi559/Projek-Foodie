import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_colors.dart';
import '../services/database_helper.dart';

class CartButton extends StatefulWidget {
  const CartButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  State<CartButton> createState() => _CartButtonState();
}

class _CartButtonState extends State<CartButton> {
  int _cartItemCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCartCount();
  }

  @override
  void didUpdateWidget(covariant CartButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadCartCount();
  }

  Future<void> _loadCartCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id') ?? 2;
      final cartItems = await DatabaseHelper.instance.getCartItems(userId);
      if (mounted) {
        setState(() {
          _cartItemCount = cartItems.length;
        });
      }
    } catch (_) {
      // Silently ignore during initialization
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Material(
            color: AppColors.card,
            shape: const CircleBorder(
              side: BorderSide(color: AppColors.borderLight, width: 1.2),
            ),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: widget.onTap,
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(
                  Icons.shopping_bag_outlined,
                  color: AppColors.textPrimary,
                  size: 22,
                ),
              ),
            ),
          ),
          if (_cartItemCount > 0)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                constraints: const BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
                child: Center(
                  child: Text(
                    '$_cartItemCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
