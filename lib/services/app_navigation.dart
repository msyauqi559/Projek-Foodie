import 'package:flutter/material.dart';

import '../models/food_item.dart';
import '../models/order_history_item.dart';
import 'app_router.dart';

/// Alur aplikasi (sesuai desain Figma):
///
/// Splash → Auth (Login / Registrasi) → Shell (Home | Categories | History | About)
///
/// Dari Home / Categories:
///   → Detail produk → My Cart → [sukses] → Shell (Home) atau Lacak (Tracking)
///
/// Dari History:
///   → Detail pembayaran (order detail)
///
/// Dari About (Profile):
///   → Logout → Auth
class AppNavigation {
  const AppNavigation._();

  // ——— Splash & Auth ———

  static void finishSplash(BuildContext context) {
    Navigator.pushReplacementNamed(context, AppRoutes.auth);
  }

  static void openLogin(BuildContext context) {
    Navigator.pushReplacementNamed(context, AppRoutes.auth);
  }

  static void onLoginSuccess(BuildContext context) {
    Navigator.pushReplacementNamed(context, AppRoutes.shell);
  }

  static void openAdmin(BuildContext context) {
    Navigator.pushReplacementNamed(context, AppRoutes.admin);
  }

  static void onLogout(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.auth,
      (_) => false,
    );
  }

  // ——— Shell (tab utama) ———

  static void openShell(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.shell,
      (_) => false,
    );
  }

  // ——— Katalog & pesanan ———

  static void openFoodDetail(BuildContext context, FoodItem food) {
    Navigator.pushNamed(context, AppRoutes.detail, arguments: food);
  }

  static void openCart(BuildContext context, FoodItem food) {
    Navigator.pushNamed(context, AppRoutes.cart, arguments: food);
  }

  static void openOrderDetail(BuildContext context, OrderHistoryItem order) {
    Navigator.pushNamed(context, AppRoutes.orderDetail, arguments: order);
  }

  static void openTracking(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.tracking);
  }

  /// Setelah checkout sukses: kembali ke Home (tab shell).
  static void finishCheckoutGoHome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.shell,
      (_) => false,
    );
  }

  /// Setelah checkout sukses: lacak pesanan (tetap di atas shell).
  static void finishCheckoutGoTracking(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.tracking,
      (route) => route.settings.name == AppRoutes.shell,
    );
  }

  static void back(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }
}
