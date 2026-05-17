import 'package:flutter/material.dart';
import 'package:xledge/services/user_prefs_service.dart';

class ThemeProvider extends ChangeNotifier {
  int _index;

  ThemeProvider() : _index = UserPrefsService.themeIndex;

  int get themeIndex => _index;

  ThemeMode get themeMode {
    switch (_index) {
      case 1:  return ThemeMode.dark;
      case 2:  return ThemeMode.system;
      default: return ThemeMode.light;
    }
  }

  Future<void> setTheme(int index) async {
    _index = index;
    await UserPrefsService.setThemeIndex(index);
    notifyListeners();
  }
}