import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_limits.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/utils/backend_error_mapper.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_gradient_button.dart';
import '../../../../core/widgets/app_screen_layout.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../auth/presentation/providers/auth_repository_provider.dart';
import '../../../posts/domain/entities/post.dart';
import '../../../posts/presentation/providers/post_repository_provider.dart';
import '../widgets/create_post_sheet.dart';
import '../widgets/post_card.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(visibleFeedPostsProvider);

    return AppScreenLayout(
      title: AppStrings.feed,
      action: _FeedActions(onCreatePost: () => showCreatePostSheet(context)),
      child: posts.when(
        data: (items) => _FeedContent(posts: items),
        loading: () => const _FeedLoadingList(),
        error: (error, stackTrace) {
          return AppEmptyState(
            icon: Icons.error_outline,
            title: AppStrings.feedEmptyTitle,
            body: BackendErrorMapper.messageFor(
              error,
              AppStrings.feedLoadFailed,
            ),
          );
        },
      ),
    );
  }
}

class _FeedActions extends StatelessWidget {
  const _FeedActions({required this.onCreatePost});

  final VoidCallback onCreatePost;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: AppStrings.createPost,
          onPressed: onCreatePost,
          icon: const Icon(Icons.add_circle_outline),
        ),
        IconButton(
          tooltip: AppStrings.openNotifications,
          onPressed: () => context.push(AppRoutes.notifications),
          icon: const Icon(Icons.notifications_none_outlined),
        ),
      ],
    );
  }
}

class _FeedContent extends ConsumerStatefulWidget {
  const _FeedContent({required this.posts});

  final List<Post> posts;

  @override
  ConsumerState<_FeedContent> createState() => _FeedContentState();
}

class _FeedContentState extends ConsumerState<_FeedContent> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pagination = ref.watch(feedPaginationControllerProvider);
    final highlightedPostId = ref.watch(feedTargetPostIdProvider);
    final currentUser = ref.watch(currentUserProvider);
    _scrollToHighlightedPost(highlightedPostId);

    if (widget.posts.isEmpty) {
      return AppEmptyState(
        icon: Icons.forum_outlined,
        title: AppStrings.feedEmptyTitle,
        body: AppStrings.feedEmptyBody,
        action: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSizes.authMaxWidth),
          child: AppGradientButton(
            label: AppStrings.createPost,
            onPressed: () => showCreatePostSheet(context),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(feedPaginationControllerProvider.notifier).reset();
        ref.invalidate(feedPostsProvider);
        try {
          await ref.read(feedPostsProvider.future);
        } catch (_) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text(AppStrings.feedLoadFailed)),
            );
          }
        }
      },
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.extentAfter <
              AppSizes.paginationLoadOffset) {
            ref
                .read(feedPaginationControllerProvider.notifier)
                .loadNextPage(currentPosts: widget.posts);
          }
          return false;
        },
        child: ListView.separated(
          key: const PageStorageKey<String>(AppRoutes.home),
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(
            bottom: AppSizes.shellScrollBottomPadding,
          ),
          itemCount: widget.posts.length + 3,
          separatorBuilder: (context, index) {
            return const SizedBox(height: AppSpacing.md);
          },
          itemBuilder: (context, index) {
            if (index == 0) {
              return const _FeedAiHint();
            }
            if (index == widget.posts.length + 2) {
              return _FeedPaginationFooter(
                state: pagination,
                onRetry: () => ref
                    .read(feedPaginationControllerProvider.notifier)
                    .loadNextPage(currentPosts: widget.posts),
              );
            }
            if (index == 1) {
              return _FeedPersonalNudge(
                currentUserId: currentUser?.id,
                posts: widget.posts,
              );
            }
            return _FeedPostCard(
              key: ValueKey(widget.posts[index - 2].id),
              post: widget.posts[index - 2],
              isHighlighted: widget.posts[index - 2].id == highlightedPostId,
            );
          },
        ),
      ),
    );
  }

  void _scrollToHighlightedPost(String? postId) {
    if (postId == null) {
      return;
    }
    final index = widget.posts.indexWhere((post) => post.id == postId);
    if (index == -1) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) {
        return;
      }
      final offset = ((index + 2) * 260.0).clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      );
      _scrollController.animateTo(
        offset,
        duration: AppDurations.pageTransition,
        curve: Curves.easeOutCubic,
      );
      ref.read(feedTargetPostIdProvider.notifier).clear();
    });
  }
}

class _FeedAiHint extends StatelessWidget {
  const _FeedAiHint();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: () => showCreatePostSheet(context),
      child: Row(
        children: [
          Icon(
            Icons.auto_awesome_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          const Expanded(
            child: Text(
              '${AppStrings.writeSomethingToday} - ${AppStrings.tryAiImproveThought}',
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedPostCard extends StatelessWidget {
  const _FeedPostCard({
    required this.post,
    required this.isHighlighted,
    super.key,
  });

  final Post post;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    return PostCard(
      post: post,
      isHighlighted: isHighlighted,
      actions: PostActionsBar(post: post),
    );
  }
}

class _FeedPersonalNudge extends StatelessWidget {
  const _FeedPersonalNudge({required this.currentUserId, required this.posts});

  final String? currentUserId;
  final List<Post> posts;

  @override
  Widget build(BuildContext context) {
    final userId = currentUserId;
    if (userId == null) {
      return const SizedBox.shrink();
    }
    final userPosts = posts.where((post) => post.userId == userId).toList();
    if (userPosts.isEmpty) {
      return const SizedBox.shrink();
    }
    final post = userPosts.first;
    final engagement = post.likesCount + post.commentsCount;

    return GlassCard(
      onTap: () => context.push(AppRoutes.commentsPath(post.id)),
      child: Row(
        children: [
          Icon(
            Icons.history_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              engagement > 0
                  ? '${AppStrings.yourRecentPost}: ${AppStrings.recentEngagement} $engagement'
                  : '${AppStrings.yourRecentPost}: ${post.text}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedPaginationFooter extends StatelessWidget {
  const _FeedPaginationFooter({required this.state, required this.onRetry});

  final FeedPaginationState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Center(
          child: SizedBox.square(
            dimension: AppSizes.buttonLoader,
            child: CircularProgressIndicator(
              strokeWidth: AppSizes.buttonLoaderStroke,
            ),
          ),
        ),
      );
    }

    if (state.error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Center(
          child: TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text(AppStrings.retry),
          ),
        ),
      );
    }

    return const SizedBox(height: AppSpacing.xs);
  }
}

class _FeedLoadingList extends StatelessWidget {
  const _FeedLoadingList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: AppSizes.shellScrollBottomPadding),
      itemCount: AppLimits.feedSkeletonPostCount,
      separatorBuilder: (context, index) {
        return const SizedBox(height: AppSpacing.md);
      },
      itemBuilder: (context, index) {
        return const _FeedLoadingCard();
      },
    );
  }
}

class _FeedLoadingCard extends StatelessWidget {
  const _FeedLoadingCard();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.card),
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.28),
      ),
      child: const Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LoadingLine(widthFactor: 0.46),
            SizedBox(height: AppSpacing.md),
            _LoadingLine(widthFactor: 0.88),
            SizedBox(height: AppSpacing.xs),
            _LoadingLine(widthFactor: 0.72),
            SizedBox(height: AppSpacing.md),
            _LoadingLine(widthFactor: 0.36),
          ],
        ),
      ),
    );
  }
}

class _LoadingLine extends StatelessWidget {
  const _LoadingLine({required this.widthFactor});

  final double widthFactor;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
        ),
        child: const SizedBox(height: AppSpacing.sm),
      ),
    );
  }
}
