import 'package:flutter/material.dart';

import '../pages/category_page.dart';
import '../pages/history_page.dart';
import '../pages/home_page.dart';
import '../pages/profile_page.dart';
import '../widgets/app_bottom_navigation_bar.dart';

/// [MainShellPage] adalah kerangka utama (Shell) aplikasi Foodie.
/// Halaman ini menggunakan Bottom Navigation Bar untuk berpindah antar tab
/// dengan mempertahankan status (state) masing-masing halaman.
class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _ProfileShellPageState();
}

class _ProfileShellPageState extends State<MainShellPage> {
  // Indeks halaman aktif saat ini (0: Beranda, 1: Kategori, 2: Riwayat, 3: Profil)
  int currentIndex = 0;

  // Daftar halaman/tab utama aplikasi yang menggunakan kata kunci 'const' agar hemat memori
  late final List<Widget> pages = [
    const HomePage(),
    const CategoryPage(),
    const HistoryPage(),
    const ProfilePage(),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Menerima argumen navigasi (indeks tab tujuan) apabila berpindah halaman dari luar shell
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is int) {
      currentIndex = args;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Menggunakan Stack untuk menempatkan navigasi bar melayang (floating) tepat di atas halaman aktif
      body: Stack(
        children: [
          // IndexedStack digunakan untuk menyimpan status scroll/data dari masing-masing tab
          // sehingga halaman tidak di-load ulang (recreated) saat berpindah tab
          IndexedStack(
            index: currentIndex,
            children: pages,
          ),
          // Memosisikan navigasi bar melayang di bagian paling bawah layar secara presisi
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false, // Hanya memberikan padding aman di bawah layar (misal notch bawah HP modern)
              child: AppBottomNavigationBar(
                currentIndex: currentIndex,
                // Mengubah status indeks aktif dan memicu render ulang (rebuild) tab yang dipilih
                onTap: (value) => setState(() => currentIndex = value),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
