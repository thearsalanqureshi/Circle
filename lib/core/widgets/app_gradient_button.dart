import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

class AppGradientButton extends StatelessWidget {
  const AppGradientButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      color: AppColors.darkTextPrimary,
      fontWeight: FontWeight.w700,
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppSizes.buttonMinHeight),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          gradient: AppColors.primaryGradient,
        ),
        child: Material(
          color: AppColors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            onTap: isLoading ? null : onPressed,
            child: Center(
              child: AnimatedSwitcher(
                duration: AppDurations.fast,
                child: isLoading
                    ? const SizedBox.square(
                        key: ValueKey('loader'),
                        dimension: AppSizes.buttonLoader,
                        child: CircularProgressIndicator(
                          strokeWidth: AppSizes.buttonLoaderStroke,
                          color: AppColors.darkTextPrimary,
                        ),
                      )
                    : Text(
                        label,
                        key: ValueKey(label),
                        textAlign: TextAlign.center,
                        style: textStyle,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
