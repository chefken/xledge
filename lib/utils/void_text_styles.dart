import 'package:flutter/material.dart';
import 'package:xledge/utils/void_colors.dart';

class VoidTextStyles {
  VoidTextStyles._();

  static const displayLarge = TextStyle(
    fontSize: 34, fontWeight: FontWeight.w700,
    color: VoidColors.textPrimary, letterSpacing: -1.0, height: 1.1,
  );
  static const headlineLarge = TextStyle(
    fontSize: 26, fontWeight: FontWeight.w700,
    color: VoidColors.textPrimary, letterSpacing: -0.6, height: 1.2,
  );
  static const headlineMedium = TextStyle(
    fontSize: 22, fontWeight: FontWeight.w600,
    color: VoidColors.textPrimary, letterSpacing: -0.4,
  );
  static const titleLarge = TextStyle(
    fontSize: 17, fontWeight: FontWeight.w600,
    color: VoidColors.textPrimary, letterSpacing: -0.2,
  );
  static const titleMedium = TextStyle(
    fontSize: 15, fontWeight: FontWeight.w500,
    color: VoidColors.textPrimary, letterSpacing: -0.1,
  );
  static const bodyLarge = TextStyle(
    fontSize: 15, fontWeight: FontWeight.w400,
    color: VoidColors.textPrimary, letterSpacing: -0.1,
  );
  static const bodyMedium = TextStyle(
    fontSize: 13, fontWeight: FontWeight.w400,
    color: VoidColors.textSecondary, letterSpacing: 0,
  );
  static const labelLarge = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w500,
    color: VoidColors.textSecondary, letterSpacing: 0.1,
  );
  static const labelSmall = TextStyle(
    fontSize: 11, fontWeight: FontWeight.w400,
    color: VoidColors.textHint, letterSpacing: 0.2,
  );
  static const amountLarge = TextStyle(
    fontSize: 32, fontWeight: FontWeight.w700,
    color: VoidColors.textOnDark, letterSpacing: -1.2, height: 1.0,
  );
  static const amountPositive = TextStyle(
    fontSize: 15, fontWeight: FontWeight.w600,
    color: VoidColors.success, letterSpacing: -0.2,
  );
  static const amountNegative = TextStyle(
    fontSize: 15, fontWeight: FontWeight.w600,
    color: VoidColors.danger, letterSpacing: -0.2,
  );
}