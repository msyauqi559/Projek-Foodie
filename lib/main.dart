import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'constants/app_colors.dart';
import 'constants/app_typography.dart';
import 'services/app_router.dart';
import 'services/database_helper.dart';

/// Entry point aplikasi — menginisialisasi database sebelum menjalankan app.
///
/// [WidgetsFlutterBinding.ensureInitialized()] WAJIB dipanggil sebelum
/// operasi async (seperti buka database) di dalam main().
/// Tanpa ini, Flutter belum siap menerima perintah platform-level.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi database SQLite jika di platform native mobile (Android/iOS)
  bool isMobile = false;
  if (!kIsWeb) {
    try {
      isMobile = Platform.isAndroid || Platform.isIOS;
    } catch (_) {}
  }

  if (isMobile) {
    await DatabaseHelper.instance.database;
  }

  runApp(const FoodieApp());
}

class FoodieApp extends StatelessWidget {
  const FoodieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Foodie',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: AppTypography.fontFamily,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.card,
        ),
        textTheme: AppTypography.textTheme,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
      ),
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
