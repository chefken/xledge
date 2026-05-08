import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:xledge/utils/void_colors.dart';
import 'package:xledge/utils/void_text_styles.dart';

class VoidTheme {
  VoidTheme._();

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
    );

    return base.copyWith(
      scaffoldBackgroundColor: VoidColors.background,
      colorScheme: const ColorScheme.light(
        primary:        VoidColors.primary,
        onPrimary:      VoidColors.onPrimary,
        secondary:      VoidColors.primaryMid,
        surface:        VoidColors.surface,
        onSurface:      VoidColors.textPrimary,
        outline:        VoidColors.outline,
      ),
      textTheme: GoogleFonts.bricolageGrotesqueTextTheme(
        base.textTheme,
      ).copyWith(
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
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
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
              borderRadius: BorderRadius.circular(100)),
          textStyle: GoogleFonts.bricolageGrotesque(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: VoidColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: VoidColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
      ),
      cardTheme: CardThemeData(
        color: VoidColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
      ),
    );
  }
}