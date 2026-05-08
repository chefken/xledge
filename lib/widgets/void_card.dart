import 'package:flutter/material.dart';
import 'package:xledge/utils/void_colors.dart';

class VoidCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double radius;
  final VoidCallback? onTap;

  const VoidCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.radius = 24,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color ?? VoidColors.surface,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: const [
            BoxShadow(
              color: VoidColors.shadowMd,
              blurRadius: 20,
              offset: Offset(0, 4),
            ),
            BoxShadow(
              color: VoidColors.shadow,
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}