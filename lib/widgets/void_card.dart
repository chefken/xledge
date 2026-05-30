import 'package:flutter/material.dart';
import 'package:xledge/utils/theme_ext.dart';

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
          color: color ?? context.xCard,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: context.xShadow,
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}