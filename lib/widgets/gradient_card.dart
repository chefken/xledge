import 'package:flutter/material.dart';
import 'package:xledge/utils/void_colors.dart';

class GradientCard extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;
  final double radius;
  final EdgeInsetsGeometry? padding;

  const GradientCard({
    super.key,
    required this.child,
    this.colors,
    this.radius = 28,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors ??
              [VoidColors.gradientStart, VoidColors.gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: VoidColors.primary.withOpacity(0.22),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}