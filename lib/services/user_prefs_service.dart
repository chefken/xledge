import 'package:hive_flutter/hive_flutter.dart';

class UserPrefsService {
  static const _boxName    = 'user_prefs';
  static const _nameKey    = 'username';
  static const _themeKey   = 'theme_mode';
  static const _catsKey    = 'custom_categories';

  static Future<void> init() async {
    await Hive.openBox(_boxName);
  }

  static Box get _box => Hive.box(_boxName);

  static String get username =>
      _box.get(_nameKey, defaultValue: 'Chef') as String;

  static Future<void> setUsername(String name) async =>
      await _box.put(_nameKey, name.trim().isEmpty ? 'Chef' : name.trim());

  static int get themeIndex =>
      _box.get(_themeKey, defaultValue: 0) as int;

  static Future<void> setThemeIndex(int index) async =>
      await _box.put(_themeKey, index);

  static List<String> get customCategories {
    final raw = _box.get(_catsKey, defaultValue: <String>[]);
    return List<String>.from(raw as List);
  }

  static Future<void> saveCustomCategories(List<String> cats) async =>
      await _box.put(_catsKey, cats);
}