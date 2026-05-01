import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xledge/utils/void_colors.dart';
import 'package:xledge/utils/void_radius.dart';
import 'package:xledge/utils/void_text_styles.dart';

class VoidTheme {
  VoidTheme._();

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: VoidColors.background,
    colorScheme: const ColorScheme.light(
      primary:        VoidColors.primary,
      onPrimary:      VoidColors.onPrimary,
      secondary:      VoidColors.primary,
      onSecondary:    VoidColors.onPrimary,
      surface:        VoidColors.surface,
      onSurface:      VoidColors.textPrimary,
      outline:        VoidColors.outline,
      outlineVariant: VoidColors.outlineVariant,
      error:          VoidColors.danger,
    ),
    textTheme: const TextTheme(
      displayLarge:   VoidTextStyles.displayLarge,
      headlineMedium: VoidTextStyles.headlineMedium,
      titleLarge:     VoidTextStyles.titleLarge,
      titleMedium:    VoidTextStyles.titleMedium,
      bodyLarge:      VoidTextStyles.bodyLarge,
      bodyMedium:     VoidTextStyles.bodyMedium,
      labelLarge:     VoidTextStyles.labelLarge,
      labelSmall:     VoidTextStyles.labelSmall,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: VoidColors.background,
      foregroundColor: VoidColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      shadowColor: VoidColors.outline,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    ),
    cardTheme: CardThemeData(
      color: VoidColors.background,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: VoidRadius.card,
        side: const BorderSide(color: VoidColors.outline, width: 1.5),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: VoidColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: VoidRadius.input,
        borderSide: const BorderSide(color: VoidColors.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: VoidRadius.input,
        borderSide: const BorderSide(color: VoidColors.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: VoidRadius.input,
        borderSide: const BorderSide(color: VoidColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: VoidRadius.input,
        borderSide: const BorderSide(color: VoidColors.danger),
      ),
      labelStyle: VoidTextStyles.labelLarge,
      hintStyle: VoidTextStyles.bodyMedium,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: VoidColors.primary,
        foregroundColor: VoidColors.onPrimary,
        elevation: 0,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: VoidRadius.button),
        textStyle: VoidTextStyles.titleMedium,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: VoidColors.primary,
      foregroundColor: VoidColors.onPrimary,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: VoidRadius.button),
      extendedTextStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
      extendedPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: VoidColors.background,
      selectedItemColor: VoidColors.primary,
      unselectedItemColor: VoidColors.textSecondary,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),
    dividerTheme: const DividerThemeData(
      color: VoidColors.outline,
      thickness: 1,
      space: 1,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: VoidColors.background,
      shape: RoundedRectangleBorder(borderRadius: VoidRadius.sheet),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: VoidColors.background,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: VoidRadius.dialog),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: VoidColors.textPrimary,
      contentTextStyle: VoidTextStyles.bodyMedium.copyWith(
        color: VoidColors.background,
      ),
      shape: RoundedRectangleBorder(borderRadius: VoidRadius.dialog),
      behavior: SnackBarBehavior.floating,
    ),
  );
}