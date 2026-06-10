import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../constants/app_colors.dart';
import '../models/food_item.dart';
import '../models/order_history_item.dart';
import '../services/app_navigation.dart';
import '../services/database_helper.dart';
import '../utils/formatters.dart';
import '../widgets/reusable_image.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  late Future<List<FoodItem>> _menusFuture;

  @override
  void initState() {
    super.initState();
    _loadMenus();
  }

  void _loadMenus() {
    setState(() {
      _menusFuture = DatabaseHelper.instance.getAllMenus();
    });
  }

  Future<void> _deleteMenu(int id) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Menu'),
        content: const Text('Yakin ingin menghapus menu ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper.instance.deleteMenu(id);
      _loadMenus();
    }
  }

  Future<void> _deleteOrder(int id) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pesanan'),
        content: const Text('Yakin ingin menghapus riwayat transaksi ini dari database?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper.instance.deletePesanan(id);
      setState(() {}); // Trigger refresh
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              tooltip: 'Logout',
              onPressed: () => AppNavigation.onLogout(context),
            )
          ],
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            tabs: [
              Tab(icon: Icon(Icons.restaurant_menu_rounded), text: 'Kelola Menu'),
              Tab(icon: Icon(Icons.receipt_long_rounded), text: 'Pesanan User'),
            ],
          ),
        ),
        floatingActionButton: Builder(
          builder: (context) {
            return FloatingActionButton.extended(
              backgroundColor: AppColors.primary,
              onPressed: () async {
                await Navigator.pushNamed(context, '/admin-form');
                _loadMenus(); // Refresh list setelah nambah
              },
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text('Tambah Menu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            );
          }
        ),
        body: TabBarView(
          children: [
            // TAB 1: KELOLA MENU
            _buildMenusTab(),

            // TAB 2: PESANAN USER
            _buildOrdersTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildMenusTab() {
    return FutureBuilder<List<FoodItem>>(
      future: _menusFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return const Center(child: Text('Belum ada menu di database.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80), // Padding bawah longgar karena ada FAB
          itemCount: items.length,
          itemBuilder: (context, index) {
            final food = items[index];
            return Card(
              color: Colors.white,
              elevation: 1,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: ReusableImage(
                    imagePath: food.imagePath,
                    width: 55,
                    height: 55,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(food.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                subtitle: Text(
                  '${food.category} • ${PriceFormatter.toRupiah(food.price)}\n${food.address}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                isThreeLine: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_rounded, color: Colors.blue),
                      onPressed: () async {
                        await Navigator.pushNamed(context, '/admin-form', arguments: food);
                        _loadMenus(); // Refresh setelah edit
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_rounded, color: Colors.red),
                      onPressed: () => _deleteMenu(food.dbId!),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showStatusDialog(BuildContext context, OrderHistoryItem order) async {
    final messenger = ScaffoldMessenger.of(context);
    final String? selectedStatus = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Status Pesanan', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Berhasil', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                leading: const Icon(Icons.check_circle_rounded, color: Colors.green),
                onTap: () => Navigator.pop(context, 'Berhasil'),
              ),
              ListTile(
                title: const Text('Gagal', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                leading: const Icon(Icons.cancel_rounded, color: Colors.red),
                onTap: () => Navigator.pop(context, 'Gagal'),
              ),
              ListTile(
                title: const Text('Belum Membayar', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                leading: const Icon(Icons.hourglass_empty_rounded, color: Colors.orange),
                onTap: () => Navigator.pop(context, 'Belum Membayar'),
              ),
            ],
          ),
        );
      },
    );

    if (selectedStatus != null) {
      await DatabaseHelper.instance.updatePesananStatus(order.dbId!, selectedStatus);
      if (mounted) {
        setState(() {});
      }
      messenger.showSnackBar(
        SnackBar(
          content: Text('Status pesanan untuk ${order.userName ?? "User"} diubah menjadi: $selectedStatus'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildOrdersTab() {
    return FutureBuilder<List<OrderHistoryItem>>(
      future: DatabaseHelper.instance.getAllPesanan(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        final orders = snapshot.data ?? [];
        if (orders.isEmpty) {
          return const Center(
            child: Text(
              'Belum ada transaksi pesanan user.',
              style: TextStyle(color: AppColors.grayText, fontSize: 15),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            
            final Color badgeBgColor;
            final Color badgeBorderColor;
            final Color badgeTextColor;

            if (order.statusLabel == 'Berhasil') {
              badgeBgColor = Colors.green.shade50;
              badgeBorderColor = Colors.green.shade300;
              badgeTextColor = Colors.green.shade800;
            } else if (order.statusLabel == 'Belum Membayar') {
              badgeBgColor = Colors.orange.shade50;
              badgeBorderColor = Colors.orange.shade300;
              badgeTextColor = Colors.orange.shade800;
            } else {
              badgeBgColor = Colors.red.shade50;
              badgeBorderColor = Colors.red.shade300;
              badgeTextColor = Colors.red.shade800;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderSubtle),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => AppNavigation.openOrderDetail(context, order),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: User Info + Delete Button
                    Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1),
                          ),
                          child: ReusableImage(
                            imagePath: (order.userPhotoPath != null && order.userPhotoPath!.isNotEmpty)
                                ? order.userPhotoPath!
                                : AppAssets.user,
                            fit: BoxFit.cover,
                            borderRadius: 15,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.userName ?? 'User Umum',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              if (order.userPhone != null && order.userPhone!.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Icon(Icons.phone_rounded, size: 11, color: AppColors.grayText),
                                    const SizedBox(width: 4),
                                    Text(
                                      order.userPhone!,
                                      style: const TextStyle(color: AppColors.grayText, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                          onPressed: () => _deleteOrder(order.dbId!),
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    
                    // Body: Food details
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: ReusableImage(
                            imagePath: order.food.imagePath,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.food.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${order.quantity} x ${PriceFormatter.toRupiah(order.food.price)}',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          PriceFormatter.toRupiah(order.total),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Footer: Date + Status Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          order.dateLabel,
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                        ),
                        InkWell(
                          onTap: () => _showStatusDialog(context, order),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: badgeBgColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: badgeBorderColor),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  order.statusLabel,
                                  style: TextStyle(
                                    color: badgeTextColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.edit_rounded,
                                  size: 11,
                                  color: badgeTextColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        },
        );
      },
    );
  }
}
