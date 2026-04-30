import 'package:flutter/material.dart';
import 'package:xledge/utils/void_theme.dart';
import 'package:xledge/utils/app_constants.dart';

class CategoryMeta {
  final Color color;
  final IconData icon;
  const CategoryMeta({required this.color, required this.icon});
}

const _meta = <String, CategoryMeta>{
  ExpenseCategory.food: CategoryMeta(
    color: Color(0xFFFF6B35),
    icon: Icons.restaurant_outlined,
  ),
  ExpenseCategory.transport: CategoryMeta(
    color: Color(0xFF00E5FF),
    icon: Icons.directions_car_outlined,
  ),
  ExpenseCategory.housing: CategoryMeta(
    color: Color(0xFF7B61FF),
    icon: Icons.home_outlined,
  ),
  ExpenseCategory.health: CategoryMeta(
    color: Color(0xFF00FF8C),
    icon: Icons.favorite_outline,
  ),
  ExpenseCategory.entertainment: CategoryMeta(
    color: Color(0xFFFFB800),
    icon: Icons.sports_esports_outlined,
  ),
  ExpenseCategory.utilities: CategoryMeta(
    color: Color(0xFF4FC3F7),
    icon: Icons.bolt_outlined,
  ),
  ExpenseCategory.clothing: CategoryMeta(
    color: Color(0xFFFF4081),
    icon: Icons.checkroom_outlined,
  ),
  ExpenseCategory.education: CategoryMeta(
    color: Color(0xFF69F0AE),
    icon: Icons.school_outlined,
  ),
  ExpenseCategory.other: CategoryMeta(
    color: VoidColors.textSecondary,
    icon: Icons.category_outlined,
  ),
};

CategoryMeta categoryMeta(String category) =>
    _meta[category] ??
    const CategoryMeta(color: VoidColors.textSecondary, icon: Icons.circle);