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
    color: VoidColors.iconColor,
    lightColor: VoidColors.iconBg,
    icon: Icons.restaurant_outlined,
  ),
  ExpenseCategory.transport: CategoryMeta(
    color: VoidColors.iconColor,
    lightColor: VoidColors.iconBg,
    icon: Icons.directions_car_outlined,
  ),
  ExpenseCategory.shopping: CategoryMeta(
    color: VoidColors.iconColor,
    lightColor: VoidColors.iconBg,
    icon: Icons.shopping_bag_outlined,
  ),
  ExpenseCategory.bills: CategoryMeta(
    color: VoidColors.iconColor,
    lightColor: VoidColors.iconBg,
    icon: Icons.receipt_long_outlined,
  ),
  ExpenseCategory.health: CategoryMeta(
    color: VoidColors.iconColor,
    lightColor: VoidColors.iconBg,
    icon: Icons.favorite_outline,
  ),
  ExpenseCategory.gym: CategoryMeta(
    color: VoidColors.iconColor,
    lightColor: VoidColors.iconBg,
    icon: Icons.fitness_center_outlined,
  ),
  ExpenseCategory.entertainment: CategoryMeta(
    color: VoidColors.primary,
    lightColor: VoidColors.primaryLight,
    icon: Icons.movie_outlined,
  ),
  ExpenseCategory.other: CategoryMeta(
    color: VoidColors.iconColor,
    lightColor: VoidColors.iconBg,
    icon: Icons.more_horiz_rounded,
  ),
};

CategoryMeta categoryMeta(String category) =>
    _map[category] ??
    const CategoryMeta(
      color: VoidColors.iconColor,
      lightColor: VoidColors.iconBg,
      icon: Icons.circle_outlined,
    );