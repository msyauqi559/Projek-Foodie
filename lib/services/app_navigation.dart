import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  static Future<void> finishSplash(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('user_id');

    if (userId != null) {
      if (!context.mounted) return;
      if (userId == -1) {
        // Jika login sebelumnya adalah admin, langsung masuk dashboard admin
        Navigator.pushReplacementNamed(context, AppRoutes.admin);
      } else {
        // Jika login sebelumnya adalah user biasa, langsung masuk main shell
        Navigator.pushReplacementNamed(context, AppRoutes.shell);
      }
    } else {
      if (!context.mounted) return;
      // Jika belum login, tampilkan layar login
      Navigator.pushReplacementNamed(context, AppRoutes.auth);
    }
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

  static Future<void> onLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('user_email');

    if (!context.mounted) return;
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

  static Future<dynamic> openFoodDetail(BuildContext context, FoodItem food) {
    return Navigator.pushNamed(context, AppRoutes.detail, arguments: food);
  }

  static Future<dynamic> openCart(BuildContext context, [FoodItem? food]) {
    return Navigator.pushNamed(context, AppRoutes.cart, arguments: food);
  }

  static void openOrderDetail(BuildContext context, OrderHistoryItem order) {
    Navigator.pushNamed(context, AppRoutes.orderDetail, arguments: order);
  }

  static void openTracking(BuildContext context, [OrderHistoryItem? order]) {
    Navigator.pushNamed(context, AppRoutes.tracking, arguments: order);
  }

  /// Setelah checkout sukses: kembali ke Home (tab shell).
  static void finishCheckoutGoHome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.shell,
      (_) => false,
    );
  }

  /// Setelah checkout sukses: kembali ke History (tab shell).
  static void finishCheckoutGoHistory(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.shell,
      (_) => false,
      arguments: 2, // Index 2 is History
    );
  }

  /// Setelah checkout sukses: lacak pesanan (tetap di atas shell).
  static void finishCheckoutGoTracking(BuildContext context, OrderHistoryItem order) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.tracking,
      (route) => route.settings.name == AppRoutes.shell,
      arguments: order,
    );
  }

  static void back(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }
}
