import 'dart:ui';

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../extensions/theme_extensions.dart';

class GradientGlowBackground extends StatelessWidget {
  const GradientGlowBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.circleColors;

    return ColoredBox(
      color: colors.background,
      child: Stack(
        children: [
          Positioned(
            top: -AppSpacing.xxl * 2,
            left: -AppSpacing.xxl,
            child: _GlowCircle(
              gradient: AppColors.purpleGlowGradient,
              sizeFactor: 0.62,
            ),
          ),
          Positioned(
            right: -AppSpacing.xxl * 1.6,
            bottom: -AppSpacing.xxl * 1.4,
            child: _GlowCircle(
              gradient: AppColors.orangeGlowGradient,
              sizeFactor: 0.6,
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: ColoredBox(color: colors.glassOverlay),
            ),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({required this.gradient, required this.sizeFactor});

  final Gradient gradient;
  final double sizeFactor;

  @override
  Widget build(BuildContext context) {
    final shortestSide = MediaQuery.sizeOf(context).shortestSide;
    final size = (shortestSide * sizeFactor)
        .clamp(AppSizes.glowCircleMin, AppSizes.glowCircleMax)
        .toDouble();

    return DecoratedBox(
      decoration: BoxDecoration(shape: BoxShape.circle, gradient: gradient),
      child: SizedBox.square(dimension: size),
    );
  }
}
