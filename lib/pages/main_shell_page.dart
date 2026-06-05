import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../pages/category_page.dart';
import '../pages/history_page.dart';
import '../pages/home_page.dart';
import '../pages/profile_page.dart';
import '../widgets/app_bottom_navigation_bar.dart';

class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int currentIndex = 0;

  late final List<Widget> pages = [
    const HomePage(),
    const CategoryPage(),
    const HistoryPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: AppBottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (value) => setState(() => currentIndex = value),
        ),
      ),
    );
  }
}
