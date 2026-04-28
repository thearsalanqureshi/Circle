import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/gradient_avatar.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    required this.title,
    required this.subtitle,
    required this.postsCount,
    required this.followersCount,
    required this.followingCount,
    this.photoUrl,
    super.key,
  });

  final String title;
  final String subtitle;
  final int postsCount;
  final int followersCount;
  final int followingCount;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final colors = context.circleColors;

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Row(
            children: [
              _ProfileAvatar(photoUrl: photoUrl),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _ProfileMetric(
                  label: AppStrings.posts,
                  value: postsCount.toString(),
                ),
              ),
              Expanded(
                child: _ProfileMetric(
                  label: AppStrings.followers,
                  value: followersCount.toString(),
                ),
              ),
              Expanded(
                child: _ProfileMetric(
                  label: AppStrings.following,
                  value: followingCount.toString(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.photoUrl});

  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final url = photoUrl;
    if (url == null || url.isEmpty) {
      return const GradientAvatar(
        icon: Icons.person_outline,
        size: AppSizes.avatarLg,
      );
    }

    return ClipOval(
      child: Image.network(
        url,
        width: AppSizes.avatarLg,
        height: AppSizes.avatarLg,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const GradientAvatar(
            icon: Icons.person_outline,
            size: AppSizes.avatarLg,
          );
        },
      ),
    );
  }
}

class _ProfileMetric extends StatelessWidget {
  const _ProfileMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.circleColors;

    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: colors.textMuted),
        ),
      ],
    );
  }
}
