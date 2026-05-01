import 'package:flutter/material.dart';
import 'package:xledge/utils/void_colors.dart';
import 'package:xledge/utils/void_constants.dart';

class CategoryMeta {
  final Color color;
  final Color lightColor;
  final IconData icon;
  const CategoryMeta({
    required this.color,
    required this.lightColor,
    required this.icon,
  });
}

const _map = <String, CategoryMeta>{
  ExpenseCategory.food: CategoryMeta(
    color: VoidColors.danger,
    lightColor: VoidColors.dangerLight,
    icon: Icons.restaurant_rounded,
  ),
  ExpenseCategory.transport: CategoryMeta(
    color: VoidColors.teal,
    lightColor: VoidColors.tealLight,
    icon: Icons.directions_car_rounded,
  ),
  ExpenseCategory.shopping: CategoryMeta(
    color: VoidColors.purple,
    lightColor: VoidColors.purpleLight,
    icon: Icons.shopping_bag_rounded,
  ),
  ExpenseCategory.health: CategoryMeta(
    color: VoidColors.success,
    lightColor: VoidColors.successLight,
    icon: Icons.favorite_rounded,
  ),
  ExpenseCategory.bills: CategoryMeta(
    color: VoidColors.warning,
    lightColor: VoidColors.warningLight,
    icon: Icons.receipt_long_rounded,
  ),
  ExpenseCategory.entertainment: CategoryMeta(
    color: VoidColors.primary,
    lightColor: VoidColors.primaryLight,
    icon: Icons.sports_esports_rounded,
  ),
  ExpenseCategory.education: CategoryMeta(
    color: VoidColors.teal,
    lightColor: VoidColors.tealLight,
    icon: Icons.school_rounded,
  ),
  ExpenseCategory.other: CategoryMeta(
    color: VoidColors.textSecondary,
    lightColor: VoidColors.surfaceVariant,
    icon: Icons.category_rounded,
  ),
};

CategoryMeta categoryMeta(String category) =>
    _map[category] ??
    const CategoryMeta(
      color: VoidColors.textSecondary,
      lightColor: VoidColors.surfaceVariant,
      icon: Icons.circle_outlined,
    );