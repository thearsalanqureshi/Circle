import 'package:flutter/material.dart';

import '../constants/app_dimensions.dart';
import '../extensions/theme_extensions.dart';
import '../utils/responsive.dart';

class AppScreenLayout extends StatelessWidget {
  const AppScreenLayout({
    required this.title,
    required this.child,
    this.action,
    super.key,
  });

  final String title;
  final Widget child;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = context.circleColors;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          context.pagePadding,
          AppSpacing.md,
          context.pagePadding,
          AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                ?action,
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
