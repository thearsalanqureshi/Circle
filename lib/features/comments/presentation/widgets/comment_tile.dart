import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/gradient_avatar.dart';
import '../../../posts/domain/entities/comment.dart';

class CommentTile extends StatelessWidget {
  const CommentTile({required this.comment, this.onLongPress, super.key});

  final Comment comment;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final colors = context.circleColors;

    return GestureDetector(
      onLongPress: onLongPress,
      child: GlassCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const GradientAvatar(icon: Icons.person_outline),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    comment.username,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    comment.text,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _timeAgo(comment.createdAt),
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(color: colors.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime? createdAt) {
    if (createdAt == null) {
      return AppStrings.now;
    }
    final difference = DateTime.now().difference(createdAt);
    if (difference.inMinutes < 1) {
      return AppStrings.now;
    }
    if (difference.inHours < 1) {
      return '${difference.inMinutes}${AppStrings.minuteShort}';
    }
    if (difference.inDays < 1) {
      return '${difference.inHours}${AppStrings.hourShort}';
    }
    return '${difference.inDays}${AppStrings.dayShort}';
  }
}
