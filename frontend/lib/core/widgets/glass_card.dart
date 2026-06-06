import 'dart:ui';

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final Color? borderColor;
  final Color? glowColor;
  final double opacity;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.margin,
    this.radius = 24,
    this.borderColor,
    this.glowColor,
    this.opacity = 0.72,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.glassLight.withValues(alpha: opacity),
                AppColors.glass.withValues(alpha: opacity * 0.82),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: borderColor ??
                  AppColors.purpleAccent.withValues(alpha: 0.22),
            ),
            boxShadow: [
              BoxShadow(
                color: (glowColor ?? AppColors.purpleAccent)
                    .withValues(alpha: 0.14),
                blurRadius: 26,
                spreadRadius: 1,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );

    final wrapped = onTap == null
        ? card
        : Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(radius),
            child: InkWell(
              borderRadius: BorderRadius.circular(radius),
              onTap: onTap,
              child: card,
            ),
          );

    return Container(
      margin: margin,
      child: wrapped,
    );
  }
}
