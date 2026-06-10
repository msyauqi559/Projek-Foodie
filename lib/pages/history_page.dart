import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_spacing.dart';
import '../models/order_history_item.dart';
import '../services/app_navigation.dart';
import '../services/database_helper.dart';
import '../widgets/app_text_field.dart';
import '../widgets/figma_page_body.dart';
import '../widgets/history_order_card.dart';

/// HistoryPage — Menampilkan riwayat pesanan dari SQLite.
///
/// Menggunakan `FutureBuilder` untuk mengambil data `OrderHistoryItem` 
/// dari tabel `tb_pesanan` yang di-JOIN dengan `tb_menu`.
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<List<OrderHistoryItem>> _ordersFuture;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _ordersFuture = _loadOrders();
    _searchCtrl.addListener(() {
      setState(() {
        _searchQuery = _searchCtrl.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<List<OrderHistoryItem>> _loadOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id') ?? 2; // Default ke 2 jika session hilang
    return DatabaseHelper.instance.getPesananByUserId(userId);
  }

  @override
  Widget build(BuildContext context) {
    return FigmaPageBody(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Text(
              'History',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppTextField(
            controller: _searchCtrl,
            hintText: 'Cari riwayat pesanan....',
            prefixIcon: Icons.search_rounded,
            borderColor: AppColors.primary,
            borderRadius: AppDimensions.tabSearchRadius,
            suffixIcon: _searchQuery.isNotEmpty ? Icons.clear_rounded : null,
            onSuffixTap: () {
              _searchCtrl.clear();
            },
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 16,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          
          // Mengambil dan menampilkan data dari SQLite
          FutureBuilder<List<OrderHistoryItem>>(
            future: _ordersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                );
              }
              
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final List<OrderHistoryItem> orders = snapshot.data ?? [];

              // Filter data berdasarkan query pencarian
              final filteredOrders = orders.where((order) {
                final query = _searchQuery.toLowerCase();
                return order.food.name.toLowerCase().contains(query) ||
                    order.food.category.toLowerCase().contains(query);
              }).toList();

              if (orders.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        Icon(Icons.receipt_long_rounded, size: 64, color: AppColors.grayMuted),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada riwayat pesanan',
                          style: TextStyle(color: AppColors.grayText, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (filteredOrders.isEmpty && _searchQuery.isNotEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        const Icon(Icons.search_off_rounded, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'Riwayat pesanan tidak ditemukan',
                          style: TextStyle(color: AppColors.grayText, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: filteredOrders.map(
                  (order) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                    child: HistoryOrderCard(
                      order: order,
                      onTap: () => AppNavigation.openOrderDetail(context, order),
                    ),
                  ),
                ).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
