import 'package:flutter/material.dart';

import '../models/food_item.dart';
import '../models/order_history_item.dart';
import '../pages/auth_page.dart';
import '../pages/cart_page.dart';
import '../pages/detail_page.dart';
import '../pages/main_shell_page.dart';
import '../pages/order_detail_page.dart';
import '../pages/order_tracking_page.dart';
import '../pages/splash_page.dart';
import '../pages/admin_dashboard_page.dart';
import '../pages/admin_menu_form_page.dart';

class AppRoutes {
  const AppRoutes._();

  static const String splash = '/';
  static const String auth = '/auth';
  static const String shell = '/shell';
  static const String detail = '/detail';
  static const String cart = '/cart';
  static const String tracking = '/tracking';
  static const String orderDetail = '/order-detail';
  static const String admin = '/admin';
  static const String adminForm = '/admin-form';
}

class AppRouter {
  const AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _fadeRoute(const SplashPage(), settings);
      case AppRoutes.auth:
        return _fadeRoute(const AuthPage(), settings);
      case AppRoutes.shell:
        return _slideRoute(const MainShellPage(), settings);
      case AppRoutes.detail:
        final FoodItem food = settings.arguments! as FoodItem;
        return _slideRoute(DetailPage(food: food), settings);
      case AppRoutes.cart:
        final FoodItem food = settings.arguments! as FoodItem;
        return _slideRoute(CartPage(food: food), settings);
      case AppRoutes.tracking:
        final OrderHistoryItem? order = settings.arguments as OrderHistoryItem?;
        return _slideRoute(
          OrderTrackingPage(order: order, showBackButton: true),
          settings,
        );
      case AppRoutes.orderDetail:
        final OrderHistoryItem order = settings.arguments! as OrderHistoryItem;
        return _slideRoute(OrderDetailPage(order: order), settings);
      case AppRoutes.admin:
        return _fadeRoute(const AdminDashboardPage(), settings);
      case AppRoutes.adminForm:
        final FoodItem? food = settings.arguments as FoodItem?;
        return _slideRoute(AdminMenuFormPage(foodToEdit: food), settings);
      default:
        return _fadeRoute(const SplashPage(), settings);
    }
  }

  static PageRouteBuilder<dynamic> _fadeRoute(
    Widget page,
    RouteSettings settings,
  ) {
    return PageRouteBuilder<dynamic>(
      settings: settings,
      pageBuilder: (_, _, _) => page,
      transitionsBuilder: (_, animation, _, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }

  static PageRouteBuilder<dynamic> _slideRoute(
    Widget page,
    RouteSettings settings,
  ) {
    return PageRouteBuilder<dynamic>(
      settings: settings,
      pageBuilder: (_, _, _) => page,
      transitionsBuilder: (_, animation, _, child) {
        const begin = Offset(1, 0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: Curves.easeOutCubic),
        );
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 280),
    );
  }
}
