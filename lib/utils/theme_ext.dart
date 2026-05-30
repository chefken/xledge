import 'package:flutter/material.dart';
import 'package:xledge/utils/void_colors.dart';

extension XTheme on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get xBg       => isDark ? VoidColors.darkBg       : VoidColors.background;
  Color get xSurface  => isDark ? VoidColors.darkSurface   : VoidColors.surface;
  Color get xCard     => isDark ? VoidColors.darkCard      : VoidColors.surface;
  Color get xBorder   => isDark ? VoidColors.darkBorder    : VoidColors.outline;
  Color get xFill     => isDark ? VoidColors.darkCard      : VoidColors.outlineVariant;
  Color get xTxPri    => isDark ? VoidColors.darkTextPrimary    : VoidColors.textPrimary;
  Color get xTxSec    => isDark ? VoidColors.darkTextSecondary  : VoidColors.textSecondary;
  Color get xTxHint   => isDark ? VoidColors.darkTextHint       : VoidColors.textHint;
  Color get xIconBg   => isDark ? VoidColors.darkIconBg    : VoidColors.iconBg;
  Color get xIconColor => isDark ? VoidColors.darkIconColor : VoidColors.iconColor;
  Color get xShadow   => isDark ? const Color(0x40000000)  : VoidColors.shadowMd;
  Color get xNavActive => isDark ? VoidColors.darkIconBg   : VoidColors.primaryLight;
}