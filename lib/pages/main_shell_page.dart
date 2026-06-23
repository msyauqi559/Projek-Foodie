import 'package:flutter/material.dart';

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is int) {
      currentIndex = args;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: currentIndex,
            children: pages,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: AppBottomNavigationBar(
                currentIndex: currentIndex,
                onTap: (value) => setState(() => currentIndex = value),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
