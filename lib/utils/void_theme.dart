import 'package:flutter/material.dart';

class VoidColors {
  static const bg = Color(0xFF080B0E);
  static const surface = Color(0xFF0F1419);
  static const card = Color(0xFF151C24);
  static const border = Color(0xFF1E2A35);
  static const accent = Color(0xFF00E5FF);
  static const accentDim = Color(0xFF007A8A);
  static const danger = Color(0xFFFF3B5C);
  static const success = Color(0xFF00FF8C);
  static const warning = Color(0xFFFFB800);
  static const textPrimary = Color(0xFFE8F4F8);
  static const textSecondary = Color(0xFF5A7A8A);
  static const textMuted = Color(0xFF2A4050);
}

class VoidTheme {
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: VoidColors.bg,
        colorScheme: const ColorScheme.dark(
          primary: VoidColors.accent,
          secondary: VoidColors.accentDim,
          surface: VoidColors.surface,
          error: VoidColors.danger,
        ),
        fontFamily: 'Courier',
        appBarTheme: const AppBarTheme(
          backgroundColor: VoidColors.bg,
          foregroundColor: VoidColors.textPrimary,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontFamily: 'Courier',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
            color: VoidColors.accent,
          ),
        ),
        cardTheme: CardThemeData(
          color: VoidColors.card,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2),
            side: const BorderSide(color: VoidColors.border),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: VoidColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(2),
            borderSide: const BorderSide(color: VoidColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(2),
            borderSide: const BorderSide(color: VoidColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(2),
            borderSide: const BorderSide(color: VoidColors.accent),
          ),
          labelStyle: const TextStyle(
            color: VoidColors.textSecondary,
            fontSize: 11,
            letterSpacing: 2,
          ),
          hintStyle: const TextStyle(color: VoidColors.textMuted),
          prefixStyle: const TextStyle(color: VoidColors.accent),
        ),
        dividerTheme: const DividerThemeData(
          color: VoidColors.border,
          thickness: 1,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: VoidColors.surface,
          selectedItemColor: VoidColors.accent,
          unselectedItemColor: VoidColors.textSecondary,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: VoidColors.textPrimary, fontSize: 13),
          bodyMedium: TextStyle(color: VoidColors.textSecondary, fontSize: 11),
          labelSmall: TextStyle(
            color: VoidColors.textSecondary,
            fontSize: 10,
            letterSpacing: 2,
          ),
        ),
      );
}