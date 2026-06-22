import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_spacing.dart';
import '../models/food_item.dart';
import '../services/app_navigation.dart';
import '../services/database_helper.dart';
import '../utils/formatters.dart';
import '../utils/responsive.dart';
import '../widgets/app_text_field.dart';
import '../widgets/figma_page_body.dart';
import '../widgets/home_brand_header.dart';
import '../widgets/cart_button.dart';
import '../widgets/reusable_image.dart';
import '../widgets/section_header.dart';

/// HomePage — Halaman utama aplikasi Foodie.
///
/// Sekarang mengambil data menu dari **SQLite** via [DatabaseHelper],
/// bukan lagi dari DummyDataService.
///
/// Menggunakan [StatefulWidget] + [FutureBuilder] untuk:
/// 1. Memanggil [DatabaseHelper.instance.getAllMenus()] saat halaman dimuat
/// 2. Menampilkan loading indicator saat data belum siap
/// 3. Menampilkan data menu saat sudah tersedia
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// Future yang menyimpan hasil query database.
  /// Dipanggil sekali di [initState], atau di-refresh saat diperlukan.
  late Future<List<FoodItem>> _menusFuture;

  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  @override
  void initState() {
    super.initState();
    _loadMenus();
    _searchCtrl.addListener(() {
      setState(() {
        _searchQuery = _searchCtrl.text.trim();
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _searchCtrl.dispose();
    super.dispose();
  }

  /// Memuat data menu dari SQLite.
  void _loadMenus() {
    _menusFuture = DatabaseHelper.instance.getAllMenus();
  }

  /// Refresh data — dipanggil setelah kembali dari halaman manage menu.
  void refreshData() {
    setState(() {
      _loadMenus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FoodItem>>(
      future: _menusFuture,
      builder: (context, snapshot) {
        // ── State 1: Loading ──
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        // ── State 2: Error ──
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        // ── State 3: Data Ready ──
        final List<FoodItem> allMenus = snapshot.data ?? [];

        final List<FoodItem> filteredMenus = allMenus.where((menu) {
          final query = _searchQuery.toLowerCase();
          final matchesQuery = menu.name.toLowerCase().contains(query) ||
              menu.category.toLowerCase().contains(query);
          
          if (_selectedCategory == 'Semua') {
            return matchesQuery;
          } else {
            return matchesQuery && menu.category == _selectedCategory;
          }
        }).toList();

        if (allMenus.isEmpty) {
          return FigmaPageBody(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header: Logo + Notifikasi ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(child: HomeBrandHeader()),
                    CartButton(
                      onTap: () async {
                        await AppNavigation.openCart(context);
                        setState(() {});
                      },
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // ── Search Bar ──
                AppTextField(
                  controller: _searchCtrl,
                  hintText: 'Cari menu....',
                  prefixIcon: Icons.search_rounded,
                  borderColor: AppColors.primary,
                  borderRadius: AppDimensions.homeSearchRadius,
                  suffixIcon: _searchQuery.isNotEmpty ? Icons.clear_rounded : null,
                  onSuffixTap: () {
                    _searchCtrl.clear(); //Bersihkan teks jika icon di klik
                  },
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 16,
                  ),
                  readOnly: true,
                ),
                const SizedBox(height: 60),

                // ── Beautiful Empty State Illustration & Message ──
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.restaurant_rounded,
                          size: 64,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'Menu Belum Tersedia',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          'Wah, saat ini toko kami belum menambahkan menu makanan baru. Silakan tunggu admin mengunggah menu lezat segera!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.grayText,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        // Salin list filteredMenus lalu urutkan dari rating terbesar ke terkecil
        final List<FoodItem> popularMenus = List<FoodItem>.from(filteredMenus) ..sort((a, b) => b.rating.compareTo(a.rating));

        // Ambil 3 menu acak untuk tampilan highlight
        final List<FoodItem> highlightMenus = (List<FoodItem>.from(filteredMenus)..shuffle()).take(3).toList();

        // Kelompokkan menu berdasarkan kategori untuk section cards
        final Map<String, List<FoodItem>> grouped = {};
        for (final menu in filteredMenus) {
          grouped.putIfAbsent(menu.category, () => []).add(menu);
        }

        // Menu Salad untuk promo banner (cari yang kategori Sehat)
        final FoodItem? promoFood = allMenus
            .where((m) => m.name.toLowerCase().contains('salad'))
            .firstOrNull;

        return FigmaPageBody(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header: Logo + Notifikasi ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(child: HomeBrandHeader()),
                  CartButton(
                    onTap: () async {
                      await AppNavigation.openCart(context);
                      setState(() {});
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Search Bar ──
              AppTextField(
                controller: _searchCtrl,
                hintText: 'Cari menu....',
                prefixIcon: Icons.search_rounded,
                borderColor: AppColors.primary,
                borderRadius: AppDimensions.homeSearchRadius,
                suffixIcon: _searchQuery.isNotEmpty ? Icons.clear_rounded : null,
                onSuffixTap: () {
                  _searchCtrl.clear();
                },
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 16,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // ── Category Chips Filter ──
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    _buildCategoryChip('Semua', Icons.restaurant_rounded),
                    const SizedBox(width: 8),
                    _buildCategoryChip('Nusantara', Icons.ramen_dining_rounded),
                    const SizedBox(width: 8),
                    _buildCategoryChip('Sehat', Icons.eco_rounded),
                    const SizedBox(width: 8),
                    _buildCategoryChip('Fastfood', Icons.local_cafe_rounded),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              if (filteredMenus.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40, bottom: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off_rounded, size: 64, color: Colors.grey),
                        const SizedBox(height: 12),
                        Text(
                          _searchQuery.isNotEmpty ? 'Menu tidak ditemukan' : 'Kategori kosong',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'Coba cari menu atau kategori makanan lainnya.'
                              : 'Saat ini belum ada menu di kategori ini.',
                          style: const TextStyle(fontSize: 13, color: AppColors.grayText),
                        ),
                      ],
                    ),
                  ),
                ),

              if (filteredMenus.isNotEmpty) ...[
                // ── Promo Banner ──
                if (promoFood != null)
                  _PromoBanner(
                    onTap: () async {
                      await AppNavigation.openFoodDetail(context, promoFood);
                      setState(() {});
                    },
                  ),
                if (promoFood != null) const SizedBox(height: AppSpacing.lg),

                // ── Quick Stats Row ──
                _QuickStatsRow(menuCount: filteredMenus.length),
                const SizedBox(height: AppSpacing.lg),

              // ── Divider ──
              Container(
                width: double.infinity,
                height: 1,
                color: AppColors.divider,
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Section: Menu Populer (Horizontal Scroll) ──
              const SectionHeader(title: '🔥 Menu Populer'),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                height: 225,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.zero,
                  itemCount: popularMenus.length > 5 ? 5 : popularMenus.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final food = popularMenus[index];
                    return _PopularMenuCard(
                      food: food,
                      onTap: () async {
                        await AppNavigation.openFoodDetail(context, food);
                        setState(() {});
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Section: Highlights dengan detail cards ──
              const SectionHeader(title: '⭐ Pilihan Hari Ini'),
              const SizedBox(height: AppSpacing.sm),
              ...List.generate(
                highlightMenus.length,
                (index) => Padding(
                  padding: EdgeInsets.only(
                    bottom: index == highlightMenus.length - 1
                        ? 0
                        : AppSpacing.md,
                  ),
                  child: _HighlightFoodCard(
                    food: highlightMenus[index],
                    rank: index + 1,
                    onDetailTap: () async {
                      await AppNavigation.openFoodDetail(
                        context,
                        highlightMenus[index],
                      );
                      setState(() {});
                    },
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Section: Per Kategori ──
              ...grouped.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CategoryHeader(
                        category: entry.key,
                        count: entry.value.length,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      SizedBox(
                        height: 130,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.zero,
                          itemCount: entry.value.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(width: AppSpacing.sm),
                          itemBuilder: (context, i) {
                            final food = entry.value[i];
                            return _MiniMenuCard(
                              food: food,
                              onTap: () async {
                                await AppNavigation.openFoodDetail(context, food);
                                setState(() {});
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      );
    },
  );
}

  Widget _buildCategoryChip(String categoryName, IconData icon) {
    final isSelected = _selectedCategory == categoryName;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = categoryName;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight.withValues(alpha: 0.8),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : AppColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              categoryName,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// WIDGET: Quick Stats Row
// ══════════════════════════════════════════════════════════

class _QuickStatsRow extends StatelessWidget {
  const _QuickStatsRow({required this.menuCount});

  final int menuCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatChip(
            icon: Icons.restaurant_menu_rounded,
            label: '$menuCount Menu',
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        const Expanded(
          child: _StatChip(
            icon: Icons.local_shipping_rounded,
            label: 'Gratis Ongkir',
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        const Expanded(
          child: _StatChip(
            icon: Icons.star_rounded,
            label: 'Rating 4.8+',
            color: AppColors.warning,
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// WIDGET: Popular Menu Card (Horizontal)
// ══════════════════════════════════════════════════════════

class _PopularMenuCard extends StatelessWidget {
  const _PopularMenuCard({required this.food, required this.onTap});

  final FoodItem food;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 155,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.8)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with glassmorphic rating badge
            Stack(
              children: [
                ReusableImage(
                  imagePath: food.imagePath,
                  width: double.infinity,
                  height: 115,
                  borderRadius: 14,
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: AppColors.warning,
                          size: 13,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          food.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              food.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
            const Spacer(),
            // Price & Delivery info
            Row(
              children: [
                Expanded(
                  child: Text(
                    PriceFormatter.toRupiah(food.price),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Icon(
                  Icons.access_time_rounded,
                  size: 12,
                  color: AppColors.grayText,
                ),
                const SizedBox(width: 2),
                Text(
                  food.deliveryTime,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    color: AppColors.grayText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// WIDGET: Highlight Food Card (Vertical List)
// ══════════════════════════════════════════════════════════

class _HighlightFoodCard extends StatelessWidget {
  const _HighlightFoodCard({
    required this.food,
    required this.rank,
    required this.onDetailTap,
  });

  final FoodItem food;
  final int rank;
  final VoidCallback onDetailTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.borderSubtle.withValues(alpha: 0.6),
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Gambar dengan badge ranking
          Stack(
            clipBehavior: Clip.none,
            children: [
              ReusableImage(
                imagePath: food.imagePath,
                width: 110,
                height: 110,
                borderRadius: 12,
              ),
              Positioned(
                top: -6,
                left: -6,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withValues(alpha: 0.8),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '#$rank',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 4),
                // Tags
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: food.tags.take(2).map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.promoCream,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tag,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 9,
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.location_on_outlined,
                        size: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        food.address,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 10.5,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    // Harga
                    Expanded(
                      child: Text(
                        PriceFormatter.toRupiah(food.price),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: AppColors.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Tombol Detail
                    SizedBox(
                      width: 72,
                      height: 32,
                      child: ElevatedButton(
                        onPressed: onDetailTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.card,
                          elevation: 0,
                          minimumSize: const Size(72, 32),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Detail',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// WIDGET: Category Header
// ══════════════════════════════════════════════════════════

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({required this.category, required this.count});

  final String category;
  final int count;

  IconData get _icon {
    switch (category) {
      case 'Nusantara':
        return Icons.ramen_dining_rounded;
      case 'Sehat':
        return Icons.eco_rounded;
      case 'Fastfood':
        return Icons.local_cafe_rounded;
      default:
        return Icons.restaurant_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(_icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 8),
        Text(
          category,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.muted,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count item',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════
// WIDGET: Mini Menu Card (Horizontal Category Row)
// ══════════════════════════════════════════════════════════

class _MiniMenuCard extends StatelessWidget {
  const _MiniMenuCard({required this.food, required this.onTap});

  final FoodItem food;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 230,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            ReusableImage(
              imagePath: food.imagePath,
              width: 80,
              height: 80,
              borderRadius: 10,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    food.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    PriceFormatter.toRupiah(food.price),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: AppColors.warning,
                          size: 12,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          food.rating.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                            color: AppColors.grayText,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.access_time_rounded,
                          size: 11,
                          color: AppColors.grayText,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          food.deliveryTime,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                            color: AppColors.grayText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// WIDGET: Promo Banner (unchanged from original)
// ══════════════════════════════════════════════════════════

class _PromoBanner extends StatelessWidget {
  const _PromoBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppDimensions.promoBannerHeight,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFF2E6), Color(0xFFFFD4B2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Decorative background circles
              Positioned(
                left: -30,
                top: -30,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                left: 80,
                bottom: -40,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: ReusableImage(
                  imagePath: AppAssets.salad,
                  width: Responsive.value(context, mobile: 220, tablet: 260),
                  height: Responsive.value(context, mobile: 180, tablet: 200),
                  fit: BoxFit.contain,
                  borderRadius: 0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double textWidth = constraints.maxWidth * 0.52;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: textWidth.clamp(170, 230),
                          child: Text(
                            'Energi alami\ndalam satu\nmangkuk\nSalad',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontSize: 20,
                                  height: 1.45,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                          ),
                        ),
                        const Spacer(),
                        SizedBox(
                          width: 120,
                          height: 36,
                          child: ElevatedButton(
                            onPressed: onTap,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.card,
                              elevation: 4,
                              shadowColor: AppColors.primary.withValues(alpha: 0.4),
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: const Text(
                              'Beli Sekarang',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
