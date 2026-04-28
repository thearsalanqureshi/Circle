import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/gradient_avatar.dart';
import '../../../posts/domain/entities/post.dart';
import '../../../posts/presentation/providers/optimistic_like_controller.dart';
import '../../../posts/presentation/providers/post_repository_provider.dart';

class PostCard extends StatefulWidget {
  const PostCard({required this.post, required this.actions, super.key});

  final Post post;
  final Widget actions;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late Widget _staticContent;

  @override
  void initState() {
    super.initState();
    _setStaticPost(widget.post);
  }

  @override
  void didUpdateWidget(PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_hasStaticPostChanged(oldWidget.post, widget.post)) {
      _setStaticPost(widget.post);
    }
  }

  void _setStaticPost(Post post) {
    _staticContent = _PostStaticContent(post: post);
    _PostRebuildLog.log('PostCardStatic', post.id);
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _staticContent,
          const SizedBox(height: AppSpacing.md),
          widget.actions,
        ],
      ),
    );
  }

  bool _hasStaticPostChanged(Post previous, Post next) {
    return previous.id != next.id ||
        previous.userId != next.userId ||
        previous.username != next.username ||
        previous.userHandle != next.userHandle ||
        previous.userPhotoUrl != next.userPhotoUrl ||
        previous.text != next.text ||
        previous.imageBase64 != next.imageBase64 ||
        previous.imageUrl != next.imageUrl ||
        previous.imagePath != next.imagePath ||
        previous.createdAt != next.createdAt;
  }
}

class _PostStaticContent extends StatelessWidget {
  const _PostStaticContent({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    final colors = context.circleColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PostHeader(post: post),
        const SizedBox(height: AppSpacing.md),
        Text(
          post.text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: colors.textPrimary,
            height: 1.42,
          ),
        ),
        if (post.imageBase64 != null || post.imageUrl != null) ...[
          const SizedBox(height: AppSpacing.md),
          _PostImagePreview(
            imageBase64: post.imageBase64,
            imageUrl: post.imageUrl,
          ),
        ],
      ],
    );
  }
}

class _PostHeader extends StatelessWidget {
  const _PostHeader({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    final colors = context.circleColors;

    return Row(
      children: [
        const GradientAvatar(icon: Icons.person_outline),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.username,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${post.userHandle} - ${_timeAgo(post.createdAt)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colors.textMuted),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: AppStrings.otherProfile,
          onPressed: () =>
              context.push(AppRoutes.otherProfilePath(post.userId)),
          icon: Icon(Icons.more_horiz, color: colors.textSecondary),
        ),
      ],
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

class _PostImagePreview extends StatelessWidget {
  const _PostImagePreview({required this.imageBase64, required this.imageUrl});

  final String? imageBase64;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final colors = context.circleColors;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: AppSizes.postImageMinHeight,
          maxHeight: AppSizes.postImageMaxHeight,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            border: Border.all(color: colors.inputBorder),
          ),
          child: _PostImageContent(
            imageBase64: imageBase64,
            imageUrl: imageUrl,
          ),
        ),
      ),
    );
  }
}

class _PostImageContent extends StatefulWidget {
  const _PostImageContent({required this.imageBase64, required this.imageUrl});

  final String? imageBase64;
  final String? imageUrl;

  @override
  State<_PostImageContent> createState() => _PostImageContentState();
}

class _PostImageContentState extends State<_PostImageContent> {
  static final _decodedBase64Cache = <String, Uint8List>{};

  String? _decodedSource;
  Uint8List? _decodedBytes;

  @override
  void initState() {
    super.initState();
    _decodeBase64IfNeeded();
  }

  @override
  void didUpdateWidget(_PostImageContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageBase64 != widget.imageBase64) {
      _decodeBase64IfNeeded();
    }
  }

  void _decodeBase64IfNeeded() {
    final base64 = widget.imageBase64;
    _decodedSource = base64;
    if (base64 == null || base64.isEmpty) {
      _decodedBytes = null;
      return;
    }

    try {
      _decodedBytes = _decodedBase64Cache.putIfAbsent(
        base64,
        () => base64Decode(base64),
      );
    } on FormatException {
      _decodedBytes = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bytes = _decodedBytes;
    if (_decodedSource != null && bytes == null) {
      return const _PostImageFallback();
    }
    if (bytes != null) {
      return Image.memory(
        bytes,
        width: double.infinity,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (context, error, stackTrace) {
          return const _PostImageFallback();
        },
      );
    }

    final url = widget.imageUrl;
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const _PostImageFallback();
        },
        loadingBuilder: (context, child, progress) {
          if (progress == null) {
            return child;
          }
          return const _PostImageFallback();
        },
      );
    }

    return const _PostImageFallback();
  }
}

class _PostImageFallback extends StatelessWidget {
  const _PostImageFallback();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: double.infinity,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: AppColors.darkTextPrimary,
          size: AppSizes.onboardingIcon,
        ),
      ),
    );
  }
}

class PostActionsBar extends StatelessWidget {
  const PostActionsBar({required this.post, super.key});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.postActionBarHeight,
      child: Row(
        children: [
          Expanded(child: _LikeActionButton(post: post)),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: _PostActionButton(
              tooltip: AppStrings.comment,
              icon: Icons.mode_comment_outlined,
              value: _compactCount(post.commentsCount),
              onPressed: () => context.push(AppRoutes.commentsPath(post.id)),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: _PostActionButton(
              tooltip: AppStrings.share,
              icon: Icons.ios_share_outlined,
              value: _compactCount(post.sharesCount),
            ),
          ),
        ],
      ),
    );
  }
}

class _LikeActionButton extends ConsumerWidget {
  const _LikeActionButton({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backendLiked = ref.watch(
      postLikedProvider(
        post.id,
      ).select((value) => value.asData?.value ?? false),
    );
    final optimistic = ref.watch(optimisticLikeControllerProvider(post.id));
    final isLiked = optimistic?.isLiked ?? backendLiked;
    final likesCount = optimistic?.likesCount ?? post.likesCount;
    _PostRebuildLog.log('PostActionsBar.like', post.id);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) {
        return;
      }
      ref
          .read(optimisticLikeControllerProvider(post.id).notifier)
          .syncWithBackend(
            backendLiked: backendLiked,
            backendLikesCount: post.likesCount,
          );
    });

    return _PostActionButton(
      tooltip: AppStrings.like,
      icon: isLiked ? Icons.favorite : Icons.favorite_border,
      value: _compactCount(likesCount),
      isActive: isLiked,
      onPressed: () async {
        final success = await ref
            .read(optimisticLikeControllerProvider(post.id).notifier)
            .toggle(baseLiked: backendLiked, baseLikesCount: post.likesCount);
        if (!success && context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text(AppStrings.likeFailed)));
        }
      },
    );
  }
}

String _compactCount(int value) {
  if (value < 1000) {
    return value.toString();
  }
  final compact = value / 1000;
  final text = compact >= 10
      ? compact.toStringAsFixed(0)
      : compact.toStringAsFixed(1);
  return '${text.replaceAll('.0', '')}K';
}

class _PostRebuildLog {
  const _PostRebuildLog._();

  static final _counts = <String, int>{};

  static void log(String widget, String postId) {
    if (!kDebugMode) {
      return;
    }
    final key = '$widget:$postId';
    final count = (_counts[key] ?? 0) + 1;
    _counts[key] = count;
    debugPrint('$widget rebuild count for postId=$postId: $count');
  }
}

class _PostActionButton extends StatelessWidget {
  const _PostActionButton({
    required this.tooltip,
    required this.icon,
    required this.value,
    this.isActive = false,
    this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final String value;
  final bool isActive;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.circleColors;
    final foreground = isActive
        ? Theme.of(context).colorScheme.primary
        : colors.textSecondary;

    return Tooltip(
      message: tooltip,
      child: SizedBox.expand(
        child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: foreground,
            minimumSize: const Size.fromHeight(AppSizes.postActionBarHeight),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            textStyle: Theme.of(context).textTheme.labelMedium,
            visualDensity: VisualDensity.compact,
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox.square(
                  dimension: AppSizes.buttonLoader,
                  child: AnimatedScale(
                    scale: isActive ? 1.14 : 1.0,
                    duration: AppDurations.fast,
                    curve: Curves.easeOutBack,
                    child: Icon(icon, size: AppSizes.buttonLoader),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                SizedBox(
                  width: AppSizes.postActionCountWidth,
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    textAlign: TextAlign.start,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: foreground,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
