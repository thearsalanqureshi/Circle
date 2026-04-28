import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/theme_extensions.dart';

class RememberMeTile extends StatelessWidget {
  const RememberMeTile({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.circleColors;

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.xs),
      onTap: () => onChanged(!value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: AppDurations.formToggle,
            width: AppSizes.buttonLoader,
            height: AppSizes.buttonLoader,
            decoration: BoxDecoration(
              color: value ? AppColors.accentOrange : AppColors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.xs),
              border: Border.all(color: AppColors.accentOrange),
            ),
            child: value
                ? const Icon(
                    Icons.check,
                    size: AppSizes.checkIcon,
                    color: AppColors.darkTextPrimary,
                  )
                : null,
          ),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              AppStrings.rememberMe,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
