import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../extensions/theme_extensions.dart';

class GradientAvatar extends StatelessWidget {
  const GradientAvatar({
    required this.icon,
    this.size = AppSizes.avatarMd,
    super.key,
  });

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.circleColors;
    final iconSize = size * 0.48;

    return DecoratedBox(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.primaryGradient,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxs),
        child: CircleAvatar(
          radius: size / 2,
          backgroundColor: colors.surfaceHigh,
          child: Icon(icon, color: colors.textPrimary, size: iconSize),
        ),
      ),
    );
  }
}
