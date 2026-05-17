import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:xledge/utils/void_colors.dart';

class VoidTheme {
  VoidTheme._();

  static TextTheme _textTheme(Color primary, Color secondary, Color hint) {
    return TextTheme(
      displayLarge: GoogleFonts.bricolageGrotesque(
          fontSize: 34, fontWeight: FontWeight.w700,
          color: primary, letterSpacing: -1.2, height: 1.1),
      headlineLarge: GoogleFonts.bricolageGrotesque(
          fontSize: 26, fontWeight: FontWeight.w700,
          color: primary, letterSpacing: -0.6, height: 1.15),
      headlineMedium: GoogleFonts.bricolageGrotesque(
          fontSize: 22, fontWeight: FontWeight.w600,
          color: primary, letterSpacing: -0.4),
      titleLarge: GoogleFonts.bricolageGrotesque(
          fontSize: 17, fontWeight: FontWeight.w600,
          color: primary, letterSpacing: -0.2),
      titleMedium: GoogleFonts.bricolageGrotesque(
          fontSize: 15, fontWeight: FontWeight.w500,
          color: primary, letterSpacing: -0.1),
      bodyLarge: GoogleFonts.bricolageGrotesque(
          fontSize: 15, fontWeight: FontWeight.w400,
          color: primary, letterSpacing: -0.1),
      bodyMedium: GoogleFonts.bricolageGrotesque(
          fontSize: 13, fontWeight: FontWeight.w400,
          color: secondary),
      labelLarge: GoogleFonts.bricolageGrotesque(
          fontSize: 12, fontWeight: FontWeight.w500,
          color: secondary, letterSpacing: 0.1),
      labelSmall: GoogleFonts.bricolageGrotesque(
          fontSize: 11, fontWeight: FontWeight.w400,
          color: hint, letterSpacing: 0.2),
    );
  }

  static ThemeData get light {
    final base = ThemeData(
        useMaterial3: true, brightness: Brightness.light);
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
              base.textTheme)
          .merge(_textTheme(VoidColors.textPrimary,
              VoidColors.textSecondary, VoidColors.textHint)),
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
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
                color: VoidColors.primary, width: 1.5)),
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
              fontSize: 15, fontWeight: FontWeight.w600),
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
    );
  }

  static ThemeData get dark {
    final base = ThemeData(
        useMaterial3: true, brightness: Brightness.dark);
    return base.copyWith(
      scaffoldBackgroundColor: VoidColors.darkBg,
      colorScheme: const ColorScheme.dark(
        primary:        VoidColors.primary,
        onPrimary:      VoidColors.onPrimary,
        secondary:      VoidColors.primaryMid,
        surface:        VoidColors.darkSurface,
        onSurface:      VoidColors.darkTextPrimary,
        outline:        VoidColors.darkBorder,
      ),
      textTheme: GoogleFonts.bricolageGrotesqueTextTheme(
              base.textTheme)
          .merge(_textTheme(VoidColors.darkTextPrimary,
              VoidColors.darkTextSecondary, VoidColors.darkTextHint)),
      appBarTheme: const AppBarTheme(
        backgroundColor: VoidColors.darkBg,
        foregroundColor: VoidColors.darkTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: VoidColors.darkCard,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
                color: VoidColors.primary, width: 1.5)),
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
              fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: VoidColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: VoidColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
      ),
      cardTheme: CardThemeData(
        color: VoidColors.darkCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
      ),
    );
  }
}