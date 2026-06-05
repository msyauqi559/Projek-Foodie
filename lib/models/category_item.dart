import 'package:flutter/material.dart';

class CategoryItem {
  const CategoryItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.itemCount,
  });

  final String id;
  final String label;
  final IconData icon;
  final int itemCount;
}
