import 'package:flutter/material.dart';

class VoidRadius {
  VoidRadius._();

  static const double xs   = 8.0;
  static const double sm   = 12.0;
  static const double md   = 16.0;
  static const double lg   = 24.0;
  static const double xl   = 32.0;
  static const double full = 100.0;

  static final card   = BorderRadius.circular(lg);
  static final chip   = BorderRadius.circular(full);
  static final button = BorderRadius.circular(full);
  static final input  = BorderRadius.circular(md);
  static final sheet  = const BorderRadius.only(
    topLeft:  Radius.circular(xl),
    topRight: Radius.circular(xl),
  );
  static final dialog = BorderRadius.circular(xl);
}