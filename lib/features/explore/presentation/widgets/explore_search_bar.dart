import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/theme_extensions.dart';

class ExploreSearchBar extends StatelessWidget {
  const ExploreSearchBar({required this.onChanged, super.key});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.circleColors;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppSizes.inputMinHeight),
      child: TextField(
        onChanged: onChanged,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: colors.textPrimary),
        decoration: const InputDecoration(
          hintText: AppStrings.searchPeople,
          prefixIcon: Icon(Icons.search_outlined),
        ),
      ),
    );
  }
}
