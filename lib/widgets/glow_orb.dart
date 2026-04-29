import 'package:flutter/material.dart';
import '../theme.dart';

class GlowOrb extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;

  const GlowOrb({
    super.key,
    this.size = 220,
    this.color = AppColors.p600,
    this.opacity = 0.12,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: opacity),
              blurRadius: size * 0.8,
              spreadRadius: size * 0.2,
            ),
          ],
          color: color.withValues(alpha: opacity * 0.25),
        ),
      ),
    );
  }
}
