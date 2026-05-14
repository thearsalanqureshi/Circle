import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/gradient_avatar.dart';
import '../../../profile/domain/entities/user_profile.dart';

class UserCard extends StatelessWidget {
  const UserCard({required this.user, super.key});

  final UserProfile user;

  @override
  Widget build(BuildContext context) {
    final colors = context.circleColors;

    return GlassCard(
      onTap: () => context.push(AppRoutes.otherProfilePath(user.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const GradientAvatar(icon: Icons.person_outline),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      _handleFor(user),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: colors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            user.bio.trim().isEmpty ? AppStrings.profileBioFallback : user.bio,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colors.textSecondary),
          ),
          if (user.interestTags.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final tag in user.interestTags.take(3))
                  Chip(
                    label: Text(tag),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.xs,
            children: [
              _UserMetric(
                label: AppStrings.posts,
                value: _formatCount(user.postsCount),
              ),
              _UserMetric(
                label: AppStrings.followers,
                value: _formatCount(user.followersCount),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _handleFor(UserProfile user) {
  final source = user.email?.split('@').first ?? user.displayName;
  final normalized = source.trim().toLowerCase().replaceAll(
    RegExp('[^a-z0-9_]+'),
    '',
  );
  return '@${normalized.isEmpty ? user.id : normalized}';
}

String _formatCount(int count) {
  if (count < 1000) {
    return count.toString();
  }
  final compact = count / 1000;
  final text = compact >= 10
      ? compact.toStringAsFixed(0)
      : compact.toStringAsFixed(1);
  return '${text.replaceAll('.0', '')}K';
}

class _UserMetric extends StatelessWidget {
  const _UserMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.circleColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: colors.textMuted),
        ),
      ],
    );
  }
}
