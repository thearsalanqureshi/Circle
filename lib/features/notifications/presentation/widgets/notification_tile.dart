import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/utils/mock_data.dart';
import '../../../../core/widgets/glass_card.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({required this.notification, super.key});

  final MockNotification notification;

  @override
  Widget build(BuildContext context) {
    final colors = context.circleColors;

    return GlassCard(
      isHighlighted: notification.unread,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: notification.unread ? AppColors.primaryGradient : null,
              color: notification.unread ? null : colors.surfaceHigh,
              border: Border.all(color: colors.inputBorder),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Icon(
                notification.icon,
                size: AppSizes.buttonLoader,
                color: notification.unread
                    ? AppColors.darkTextPrimary
                    : colors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      notification.time,
                      style: Theme.of(
                        context,
                      ).textTheme.labelSmall?.copyWith(color: colors.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  notification.body,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: colors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
