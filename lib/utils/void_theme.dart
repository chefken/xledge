import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xledge/utils/void_colors.dart';
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
      secondary:      VoidColors.primaryMid,
      surface:        VoidColors.surface,
      onSurface:      VoidColors.textPrimary,
      outline:        VoidColors.outline,
    ),
    textTheme: const TextTheme(
      displayLarge:   VoidTextStyles.displayLarge,
      headlineLarge:  VoidTextStyles.headlineLarge,
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
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: VoidColors.outlineVariant,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide:
            const BorderSide(color: VoidColors.primary, width: 1.5),
      ),
      labelStyle: VoidTextStyles.bodyMedium,
      hintStyle: VoidTextStyles.bodyMedium,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: VoidColors.primary,
        foregroundColor: VoidColors.onPrimary,
        elevation: 0,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: VoidColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: VoidColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24)),
    ),
  );
}