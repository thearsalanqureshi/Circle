import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/theme/theme_mode_controller.dart';
import '../../../../core/widgets/glass_card.dart';

class ProfileThemeSelector extends ConsumerWidget {
  const ProfileThemeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMode = ref.watch(themeModeControllerProvider);
    final colors = context.circleColors;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.theme,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _ThemeChip(
                label: AppStrings.themeSystem,
                mode: ThemeMode.system,
                selectedMode: selectedMode,
              ),
              _ThemeChip(
                label: AppStrings.themeLight,
                mode: ThemeMode.light,
                selectedMode: selectedMode,
              ),
              _ThemeChip(
                label: AppStrings.themeDark,
                mode: ThemeMode.dark,
                selectedMode: selectedMode,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ThemeChip extends ConsumerWidget {
  const _ThemeChip({
    required this.label,
    required this.mode,
    required this.selectedMode,
  });

  final String label;
  final ThemeMode mode;
  final ThemeMode selectedMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.circleColors;
    final selected = selectedMode == mode;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: AppColors.accentPink.withValues(alpha: 0.22),
      backgroundColor: colors.surfaceHigh,
      side: BorderSide(
        color: selected ? AppColors.accentOrange : colors.inputBorder,
      ),
      labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: selected ? colors.textPrimary : colors.textSecondary,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      ),
      onSelected: (_) {
        ref.read(themeModeControllerProvider.notifier).setThemeMode(mode);
      },
    );
  }
}
