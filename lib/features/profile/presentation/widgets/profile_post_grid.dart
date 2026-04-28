import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_limits.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../posts/domain/entities/post.dart';
import '../../../posts/presentation/providers/post_repository_provider.dart';
import '../providers/profile_tab_controller.dart';

class ProfilePostGrid extends ConsumerWidget {
  const ProfilePostGrid({
    required this.userId,
    this.respectProfileTabs = true,
    super.key,
  });

  final String userId;
  final bool respectProfileTabs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(profileTabControllerProvider);
    if (respectProfileTabs && selected == ProfileTab.saved) {
      return const AppEmptyState(
        icon: Icons.bookmark_border_outlined,
        title: AppStrings.noSavedPosts,
        body: AppStrings.profilePostsEmptyBody,
      );
    }

    final posts = ref.watch(visibleUserPostsProvider(userId));
    return posts.when(
      data: (items) => _ProfilePostGridContent(posts: items),
      loading: () => const _ProfilePostGridLoading(),
      error: (error, stackTrace) => const AppEmptyState(
        icon: Icons.error_outline,
        title: AppStrings.profilePostsEmptyTitle,
        body: AppStrings.profileLoadFailed,
      ),
    );
  }
}

class _ProfilePostGridLoading extends StatelessWidget {
  const _ProfilePostGridLoading();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columnCount = width >= AppBreakpoints.mobile ? 4 : 3;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: AppLimits.profileSkeletonTileCount,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columnCount,
            mainAxisSpacing: AppSpacing.sm,
            crossAxisSpacing: AppSpacing.sm,
            childAspectRatio: AppSizes.profileGridAspect,
          ),
          itemBuilder: (context, index) {
            return DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.08),
              ),
            );
          },
        );
      },
    );
  }
}

class _ProfilePostGridContent extends StatelessWidget {
  const _ProfilePostGridContent({required this.posts});

  final List<Post> posts;

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return const AppEmptyState(
        icon: Icons.grid_on_outlined,
        title: AppStrings.profilePostsEmptyTitle,
        body: AppStrings.profilePostsEmptyBody,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columnCount = width >= AppBreakpoints.mobile ? 4 : 3;

        return GridView.builder(
          key: const PageStorageKey<String>('profile-post-grid'),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: posts.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columnCount,
            mainAxisSpacing: AppSpacing.sm,
            crossAxisSpacing: AppSpacing.sm,
            childAspectRatio: AppSizes.profileGridAspect,
          ),
          itemBuilder: (context, index) {
            return _ProfilePostTile(
              key: ValueKey(posts[index].id),
              post: posts[index],
            );
          },
        );
      },
    );
  }
}

class _ProfilePostTile extends StatelessWidget {
  const _ProfilePostTile({required this.post, super.key});

  static final _decodedBase64Cache = <String, Uint8List>{};

  final Post post;

  @override
  Widget build(BuildContext context) {
    if (post.imageBase64 != null) {
      try {
        final bytes = _decodedBase64Cache.putIfAbsent(
          post.imageBase64!,
          () => base64Decode(post.imageBase64!),
        );
        return ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: Image.memory(
            bytes,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            errorBuilder: (context, error, stackTrace) {
              return _TextPostTile(post: post);
            },
          ),
        );
      } on FormatException {
        return _TextPostTile(post: post);
      }
    }

    if (post.imageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Image.network(
          post.imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _TextPostTile(post: post);
          },
        ),
      );
    }

    return _TextPostTile(post: post);
  }
}

class _TextPostTile extends StatelessWidget {
  const _TextPostTile({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        gradient: AppColors.primaryGradient,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.notes_outlined,
              color: AppColors.darkTextPrimary,
              size: AppSizes.emptyStateIcon,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              post.text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.darkTextPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
