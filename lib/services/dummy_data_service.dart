import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../models/category_item.dart';
import '../models/food_item.dart';
import '../models/order_history_item.dart';

class DummyDataService {
  const DummyDataService._();

  static const List<CategoryItem> categories = [
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

  static const List<FoodItem> foods = [
    FoodItem(
      id: 'mie-ayam',
      name: 'Mie Ayam Tunggal Rasa',
      category: 'Nusantara',
      address: 'Jl. Imam Bonjol, No.19 Pasuruan',
      description:
          'Masakan Indonesia yang terbuat dari mi kuning direbus mendidih kemudian ditaburi saus kecap khusus beserta daging ayam dan sayuran.',
      imagePath: AppAssets.mieAyam,
      price: 15000,
      rating: 4.9,
      deliveryTime: '12 min',
      distance: '900 m',
      calories: 340,
      tags: ['Favorite', 'Gurih', 'Fresh'],
    ),
    FoodItem(
      id: 'rendang',
      name: 'Rendang Daging',
      category: 'Nusantara',
      address: 'Jl. Imam Bonjol, No.19 Pasuruan',
      description:
          'Rendang dengan bumbu rempah kaya rasa, daging empuk, dan plating khas Nusantara yang menggugah selera.',
      imagePath: AppAssets.rendang,
      price: 45000,
      rating: 4.9,
      deliveryTime: '20 min',
      distance: '1.8 km',
      calories: 420,
      tags: ['Best Seller', 'Pedas', 'Bumbu Pekat'],
    ),
    FoodItem(
      id: 'rawon',
      name: 'Rawon',
      category: 'Nusantara',
      address: 'Jl. Imam Bonjol, No.19 Pasuruan',
      description:
          'Rawon khas Jawa Timur dengan kuah hitam pekat, daging empuk, dan pelengkap telur serta sambal.',
      imagePath: AppAssets.rawon,
      price: 20000,
      rating: 4.9,
      deliveryTime: '18 min',
      distance: '1.1 km',
      calories: 390,
      tags: ['Kuah Gurih', 'Lokal', 'Hangat'],
    ),
    FoodItem(
      id: 'bakso',
      name: 'Bakso solo',
      category: 'Nusantara',
      address: 'Jl. Diponegoro Kota pasuruan',
      description:
          'Bakso solo dengan kuah kaldu gurih, mie, dan potongan bakso sapi yang lembut.',
      imagePath: AppAssets.bakso,
      price: 15000,
      rating: 4.8,
      deliveryTime: '15 min',
      distance: '1.2 km',
      calories: 360,
      tags: ['Hangat', 'Laris', 'Comfort Food'],
    ),
    FoodItem(
      id: 'salad',
      name: 'Salad',
      category: 'Sehat',
      address: 'Jl. Imam Bonjol, No.19 Pasuruan',
      description:
          'Salad sayur segar dengan telur, tomat, timun, dan dressing ringan yang cocok untuk makanan sehat.',
      imagePath: AppAssets.salad,
      price: 25000,
      rating: 4.9,
      deliveryTime: '10 min',
      distance: '700 m',
      calories: 190,
      tags: ['Low Calorie', 'Fresh', 'Diet Friendly'],
    ),
    FoodItem(
      id: 'gado-gado',
      name: 'Gado - gado',
      category: 'Sehat',
      address: 'Jl. Imam Bonjol, No.19 Pasuruan',
      description:
          'Gado-gado dengan sayuran rebus, telur, tahu, dan saus kacang gurih yang autentik.',
      imagePath: AppAssets.lontongBalap,
      price: 12000,
      rating: 4.9,
      deliveryTime: '13 min',
      distance: '850 m',
      calories: 280,
      tags: ['Sehat', 'Murah', 'Sayur Lengkap'],
    ),
    FoodItem(
      id: 'buah-kemasan',
      name: 'Buah buahan kemasan (bebas request)',
      category: 'Sehat',
      address: 'bebas request',
      description:
          'Buah segar dalam kemasan praktis. Isi bisa disesuaikan sesuai request selama stok tersedia.',
      imagePath: AppAssets.packagedFruit,
      price: 15000,
      rating: 4.9,
      deliveryTime: '9 min',
      distance: '600 m',
      calories: 150,
      tags: ['Fresh', 'Praktis', 'Bebas Request'],
    ),
    FoodItem(
      id: 'lontong-balap',
      name: 'Lontong Balap',
      category: 'Fastfood',
      address: 'Jl. Imam Bonjol, No.19 Pasuruan',
      description:
          'Lontong balap dengan tahu, lentho, tauge, dan kuah gurih khas Surabaya.',
      imagePath: AppAssets.lontongBalap,
      price: 15000,
      rating: 4.9,
      deliveryTime: '14 min',
      distance: '1.0 km',
      calories: 310,
      tags: ['Cepat Saji', 'Gurih', 'Lokal'],
    ),
    FoodItem(
      id: 'kebab',
      name: 'Fastfood Special',
      category: 'Fastfood',
      address: 'Jl. Imam Bonjol, No.19 Pasuruan',
      description:
          'Menu cepat saji dengan rasa gurih dan penyajian cepat untuk makan praktis.',
      imagePath: AppAssets.kebab,
      price: 18000,
      rating: 4.8,
      deliveryTime: '11 min',
      distance: '950 m',
      calories: 280,
      tags: ['Cepat', 'Praktis', 'Camilan'],
    ),
    FoodItem(
      id: 'fast-buah',
      name: 'Buah buahan kemasan',
      category: 'Fastfood',
      address: 'bebas request',
      description:
          'Buah segar praktis siap santap untuk camilan cepat saat beraktivitas.',
      imagePath: AppAssets.packagedFruit,
      price: 15000,
      rating: 4.9,
      deliveryTime: '9 min',
      distance: '600 m',
      calories: 150,
      tags: ['Fresh', 'Cepat', 'Praktis'],
    ),
  ];

  static final List<OrderHistoryItem> orderHistory = [
    OrderHistoryItem(
      id: 'history-1',
      food: foods[0],
      quantity: 1,
      dateLabel: 'Yesterday',
      statusLabel: 'Berhasil',
      isSuccess: true,
      total: 19500,
      promoDiscount: 2000,
      shippingCost: 5000,
      tax: 1500,
      promoCode: '872008',
    ),
    OrderHistoryItem(
      id: 'history-2',
      food: foods[1],
      quantity: 2,
      dateLabel: '4 Day Ago',
      statusLabel: 'GAGAL',
      isSuccess: false,
      total: 90000,
      promoDiscount: 0,
      shippingCost: 5000,
      tax: 3000,
      promoCode: '872008',
    ),
    OrderHistoryItem(
      id: 'history-3',
      food: foods[5],
      quantity: 5,
      dateLabel: 'Today',
      statusLabel: 'GAGAL',
      isSuccess: false,
      total: 60000,
      promoDiscount: 0,
      shippingCost: 5000,
      tax: 6000,
      promoCode: '872008',
    ),
    OrderHistoryItem(
      id: 'history-4',
      food: foods[5],
      quantity: 1,
      dateLabel: 'Today',
      statusLabel: 'Berhasil',
      isSuccess: true,
      total: 12000,
      promoDiscount: 0,
      shippingCost: 5000,
      tax: 1200,
      promoCode: '872008',
    ),
  ];

  static FoodItem get featuredFood => foods[0];

  static List<FoodItem> foodsByCategory(String categoryLabel) {
    if (categoryLabel == 'Semua') {
      return foods;
    }

    return foods.where((item) => item.category == categoryLabel).toList();
  }

  static List<FoodItem> get homeFoods => [foods[0], foods[3], foods[7]];

  static List<FoodItem> get nusantaraFoods =>
      foods.where((item) => item.category == 'Nusantara').take(3).toList();

  static List<FoodItem> get healthyFoods =>
      foods.where((item) => item.category == 'Sehat').take(3).toList();

  static List<FoodItem> get fastFoods =>
      foods.where((item) => item.category == 'Fastfood').take(3).toList();
}
