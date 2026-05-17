import 'package:flutter/material.dart';
import 'package:xledge/services/user_prefs_service.dart';
import 'package:xledge/utils/void_constants.dart';

class CategoryService extends ChangeNotifier {
  List<String> _custom = [];

  CategoryService() {
    _custom = UserPrefsService.customCategories;
  }

  List<String> get all => [
        ...ExpenseCategory.all,
        ..._custom,
      ];

  List<String> get custom => List.unmodifiable(_custom);

  bool isDefault(String cat) => ExpenseCategory.all.contains(cat);

  Future<bool> addCategory(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return false;
    final lower = trimmed.toLowerCase();
    final exists = all.any((c) => c.toLowerCase() == lower);
    if (exists) return false;
    _custom.add(trimmed);
    await UserPrefsService.saveCustomCategories(_custom);
    notifyListeners();
    return true;
  }

  Future<void> removeCustom(String name) async {
    _custom.remove(name);
    await UserPrefsService.saveCustomCategories(_custom);
    notifyListeners();
  }
}