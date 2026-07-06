import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:xledge/utils/void_colors.dart';

class VoidTextStyles {
  VoidTextStyles._();

  static TextStyle get displayLarge => GoogleFonts.bricolageGrotesque(
    fontSize: 34, fontWeight: FontWeight.w700,
    color: VoidColors.textPrimary, letterSpacing: -1.2, height: 1.1,
  );
  static TextStyle get headlineLarge => GoogleFonts.bricolageGrotesque(
    fontSize: 26, fontWeight: FontWeight.w700,
    color: VoidColors.textPrimary, letterSpacing: -0.6, height: 1.15,
  );
  static TextStyle get headlineMedium => GoogleFonts.bricolageGrotesque(
    fontSize: 22, fontWeight: FontWeight.w600,
    color: VoidColors.textPrimary, letterSpacing: -0.4,
  );
  static TextStyle get titleLarge => GoogleFonts.bricolageGrotesque(
    fontSize: 17, fontWeight: FontWeight.w600,
    color: VoidColors.textPrimary, letterSpacing: -0.2,
  );
  static TextStyle get titleMedium => GoogleFonts.bricolageGrotesque(
    fontSize: 15, fontWeight: FontWeight.w500,
    color: VoidColors.textPrimary, letterSpacing: -0.1,
  );
  static TextStyle get bodyLarge => GoogleFonts.bricolageGrotesque(
    fontSize: 15, fontWeight: FontWeight.w400,
    color: VoidColors.textPrimary, letterSpacing: -0.1,
  );
  static TextStyle get bodyMedium => GoogleFonts.bricolageGrotesque(
    fontSize: 13, fontWeight: FontWeight.w400,
    color: VoidColors.textSecondary,
  );
  static TextStyle get labelLarge => GoogleFonts.bricolageGrotesque(
    fontSize: 12, fontWeight: FontWeight.w500,
    color: VoidColors.textSecondary, letterSpacing: 0.1,
  );
  static TextStyle get labelSmall => GoogleFonts.bricolageGrotesque(
    fontSize: 11, fontWeight: FontWeight.w400,
    color: VoidColors.textHint, letterSpacing: 0.2,
  );
  static TextStyle get amountPositive => GoogleFonts.bricolageGrotesque(
    fontSize: 15, fontWeight: FontWeight.w600,
    color: VoidColors.success, letterSpacing: -0.2,
  );
  static TextStyle get amountNegative => GoogleFonts.bricolageGrotesque(
    fontSize: 15, fontWeight: FontWeight.w600,
    color: VoidColors.danger, letterSpacing: -0.2,
  );
}