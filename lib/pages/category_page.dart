import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../models/category_item.dart';
import '../models/food_item.dart';
import '../services/app_navigation.dart';
import '../services/database_helper.dart';
import '../constants/app_dimensions.dart';
import '../widgets/app_text_field.dart';
import '../widgets/category_food_card.dart';
import '../widgets/figma_page_body.dart';
import '../widgets/section_header.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key, this.initialCategory});

  final String? initialCategory;

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late String selectedCategory;
  late Future<List<FoodItem>> _menusFuture;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.initialCategory ?? 'Semua';
    _loadMenus();
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

  void _loadMenus() {
    setState(() {
      _menusFuture = DatabaseHelper.instance.getAllMenus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FigmaPageBody(
      hasBottomNavBar: true,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Kategori Menu',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: AppSpacing.xl),
          AppTextField(
            controller: _searchCtrl,
            hintText: 'Cari menu....',
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
          _CategoryChipsRow(
            selectedCategory: selectedCategory,
            onSelected: (label) => setState(() => selectedCategory = label),
          ),
          const SizedBox(height: AppSpacing.xl),
          
          FutureBuilder<List<FoodItem>>(
            future: _menusFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                );
              }

              final allMenus = snapshot.data ?? [];
              
              if (allMenus.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.restaurant_rounded, size: 54, color: AppColors.primary),
                      SizedBox(height: 16),
                      Text(
                        'Belum ada menu makanan.',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Silakan tunggu admin mengunggah menu lezat segera.',
                        style: TextStyle(color: AppColors.grayText, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              // Filter data berdasarkan query pencarian
              final filteredMenus = allMenus.where((m) {
                final query = _searchQuery.toLowerCase();
                return m.name.toLowerCase().contains(query) ||
                    m.category.toLowerCase().contains(query);
              }).toList();
              
              // Filter data berdasarkan SQLite records
              final nusantaraFoods = filteredMenus.where((m) => m.category == 'Nusantara').toList();
              final healthyFoods = filteredMenus.where((m) => m.category == 'Sehat').toList();
              final fastFoods = filteredMenus.where((m) => m.category == 'Fastfood').toList();

              return Column(
                children: [
                  if ((selectedCategory == 'Semua' || selectedCategory == 'Nusantara') && nusantaraFoods.isNotEmpty)
                    _FoodSection(
                      title: 'Nusantara',
                      foods: nusantaraFoods,
                    ),
                  if ((selectedCategory == 'Semua' || selectedCategory == 'Sehat') && healthyFoods.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xl),
                    _FoodSection(
                      title: 'Makanan Sehat',
                      foods: healthyFoods,
                    ),
                  ],
                  if ((selectedCategory == 'Semua' || selectedCategory == 'Fastfood') && fastFoods.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xl),
                    _FoodSection(
                      title: 'Makanan Cepat Saji',
                      foods: fastFoods,
                    ),
                  ],
                  
                  // Empty state jika pencarian tidak ditemukan
                  if (filteredMenus.isEmpty && _searchQuery.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded, size: 54, color: Colors.grey),
                          SizedBox(height: 12),
                          Text(
                            'Menu tidak ditemukan',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Coba cari kata kunci lainnya.',
                            style: TextStyle(color: AppColors.grayText, fontSize: 13),
                          ),
                        ],
                      ),
                    ),

                  // Empty state jika kategori kosong
                  if (selectedCategory != 'Semua' && _searchQuery.isEmpty &&
                      ((selectedCategory == 'Nusantara' && nusantaraFoods.isEmpty) ||
                       (selectedCategory == 'Sehat' && healthyFoods.isEmpty) ||
                       (selectedCategory == 'Fastfood' && fastFoods.isEmpty)))
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.restaurant_rounded, size: 54, color: Colors.orange.shade700),
                          const SizedBox(height: 12),
                          const Text(
                            'Kategori Kosong',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Saat ini belum ada menu makanan untuk kategori ini.',
                            style: TextStyle(color: AppColors.grayText, fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      ),
    );
  }
}

class _CategoryChipsRow extends StatelessWidget {
  const _CategoryChipsRow({
    required this.selectedCategory,
    required this.onSelected,
  });

  final String selectedCategory;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _staticCategories.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _CategoryTab(
                    item: item,
                    isSelected: selectedCategory == item.label,
                    onTap: () => onSelected(item.label),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

class _CategoryTab extends StatelessWidget {
  const _CategoryTab({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final CategoryItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            width: 110,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.card,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.borderLight,
                width: 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        blurRadius: 10,
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
            child: Text(
              item.label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isSelected ? AppColors.card : AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FoodSection extends StatelessWidget {
  const _FoodSection({
    required this.title,
    required this.foods,
  });

  final String title;
  final List<FoodItem> foods;

  static const double _cardGap = 12;
  static const double _sectionHeight = 220;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(title: title),
          const SizedBox(height: AppSpacing.sm),
          LayoutBuilder(
            builder: (context, constraints) {
              final cards = foods
                  .map(
                    (food) => CategoryFoodCard(
                      food: food,
                      onTap: () =>
                          AppNavigation.openFoodDetail(context, food),
                    ),
                  )
                  .toList();

              return SizedBox(
                height: _sectionHeight,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.zero,
                  itemCount: cards.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(width: _cardGap),
                  itemBuilder: (context, index) => cards[index],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

const List<CategoryItem> _staticCategories = [
  CategoryItem(
    id: 'all',
    label: 'Semua',
    icon: Icons.grid_view_rounded,
    itemCount: 6,
  ),
  CategoryItem(
    id: 'nusantara',
    label: 'Nusantara',
    icon: Icons.ramen_dining_rounded,
    itemCount: 4,
  ),
  CategoryItem(
    id: 'healthy',
    label: 'Sehat',
    icon: Icons.eco_rounded,
    itemCount: 3,
  ),
  CategoryItem(
    id: 'fastfood',
    label: 'Fastfood',
    icon: Icons.local_cafe_rounded,
    itemCount: 3,
  ),
];
