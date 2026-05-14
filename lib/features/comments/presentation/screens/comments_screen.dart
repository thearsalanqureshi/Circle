import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_limits.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/utils/backend_error_mapper.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_banner.dart';
import '../../../../core/widgets/app_screen_layout.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/gradient_glow_background.dart';
import '../../../posts/domain/entities/comment.dart';
import '../../../posts/domain/entities/post.dart';
import '../../../posts/presentation/providers/post_repository_provider.dart';
import '../providers/add_comment_controller.dart';
import '../providers/smart_reply_controller.dart';
import '../widgets/comment_tile.dart';

final _highlightedCommentIdProvider = NotifierProvider.autoDispose
    .family<_HighlightedCommentController, String?, String>(
      _HighlightedCommentController.new,
    );

class _HighlightedCommentController extends Notifier<String?> {
  _HighlightedCommentController(this._postId);

  final String _postId;

  @override
  String? build() {
    return null;
  }

  void set(String commentId) {
    if (kDebugMode) {
      debugPrint(
        'Highlighted comment for postId=$_postId commentId=$commentId',
      );
    }
    state = commentId;
  }
}

class CommentsScreen extends ConsumerStatefulWidget {
  const CommentsScreen({required this.postId, super.key});

  final String postId;

  @override
  ConsumerState<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends ConsumerState<CommentsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  final _commentFocusNode = FocusNode();
  final _commentsScrollController = ScrollController();

  String? _lastCommentSignature;
  int _lastCommentCount = 0;
  bool _hasRenderedInitialComments = false;

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    _commentsScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final comments = ref.watch(postCommentsProvider(widget.postId));
    final addState = ref.watch(addCommentControllerProvider);
    final smartReplies = ref.watch(smartReplyControllerProvider);
    final parentPost = ref.watch(postByIdProvider(widget.postId));
    final highlightedCommentId = ref.watch(
      _highlightedCommentIdProvider(widget.postId),
    );

    return GradientGlowBackground(
      child: Scaffold(
        backgroundColor: AppColors.transparent,
        body: AppScreenLayout(
          title: AppStrings.comments,
          action: IconButton(
            tooltip: AppStrings.close,
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.close),
          ),
          child: Column(
            children: [
              Expanded(
                child: comments.when(
                  data: (items) {
                    _scheduleCommentContinuity(items);
                    return _CommentsList(
                      controller: _commentsScrollController,
                      comments: items,
                      parentPost: parentPost,
                      highlightedCommentId: highlightedCommentId,
                      onCommentLongPress: (comment) {
                        _generateSmartReplies(comment, items);
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) => AppEmptyState(
                    icon: Icons.error_outline,
                    title: AppStrings.commentsEmptyTitle,
                    body: BackendErrorMapper.messageFor(
                      error,
                      AppStrings.commentsLoadFailed,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (addState.hasError) ...[
                AppErrorBanner(
                  message: BackendErrorMapper.messageFor(
                    addState.error!,
                    AppStrings.commentFailed,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              const _ReplyWithAiHint(),
              const SizedBox(height: AppSpacing.sm),
              _SmartReplySuggestions(
                state: smartReplies,
                onSelected: (suggestion) {
                  _commentController.text = suggestion;
                  _commentFocusNode.requestFocus();
                  ref.read(smartReplyControllerProvider.notifier).clear();
                },
                onDismiss: () {
                  ref.read(smartReplyControllerProvider.notifier).clear();
                },
                onRetry: () {
                  ref.read(smartReplyControllerProvider.notifier).retry();
                },
              ),
              _CommentComposer(
                controller: _commentController,
                focusNode: _commentFocusNode,
                formKey: _formKey,
                isLoading: addState.isLoading,
                onSubmit: _addComment,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addComment() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    final added = await ref
        .read(addCommentControllerProvider.notifier)
        .addComment(postId: widget.postId, text: _commentController.text);

    if (!added || !mounted) {
      return;
    }

    _commentController.clear();
    _commentFocusNode.requestFocus();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text(AppStrings.commentAdded)));
  }

  void _scheduleCommentContinuity(List<Comment> comments) {
    final newestId = comments.isEmpty ? null : comments.last.id;
    final signature = '${comments.length}:$newestId';
    if (_lastCommentSignature == signature) {
      return;
    }

    final shouldHighlight =
        _hasRenderedInitialComments &&
        comments.length > _lastCommentCount &&
        newestId != null;
    _lastCommentSignature = signature;
    _lastCommentCount = comments.length;
    _hasRenderedInitialComments = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      if (shouldHighlight) {
        ref
            .read(_highlightedCommentIdProvider(widget.postId).notifier)
            .set(newestId);
      }
      if (!_commentsScrollController.hasClients) {
        return;
      }
      _commentsScrollController.animateTo(
        _commentsScrollController.position.maxScrollExtent,
        duration: AppDurations.pageTransition,
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _generateSmartReplies(Comment comment, List<Comment> comments) {
    final context = comments
        .where((item) => item.id != comment.id)
        .map((item) => item.text)
        .take(3)
        .toList();
    ref
        .read(smartReplyControllerProvider.notifier)
        .generate(commentText: comment.text, context: context);
  }
}

class _ReplyWithAiHint extends StatelessWidget {
  const _ReplyWithAiHint();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.auto_awesome_outlined,
          size: AppSizes.checkIcon,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            '${AppStrings.replyWithAi}: ${AppStrings.smartReplyHint}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

class _CommentsList extends StatelessWidget {
  const _CommentsList({
    required this.controller,
    required this.comments,
    required this.onCommentLongPress,
    this.parentPost,
    this.highlightedCommentId,
  });

  final ScrollController controller;
  final List<Comment> comments;
  final Post? parentPost;
  final String? highlightedCommentId;
  final ValueChanged<Comment> onCommentLongPress;

  @override
  Widget build(BuildContext context) {
    if (comments.isEmpty) {
      return ListView(
        controller: controller,
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        children: [
          if (parentPost != null) ...[
            _ParentPostCard(post: parentPost!),
            const SizedBox(height: AppSpacing.md),
          ],
          const AppEmptyState(
            icon: Icons.mode_comment_outlined,
            title: AppStrings.commentsEmptyTitle,
            body: AppStrings.commentsEmptyBody,
          ),
        ],
      );
    }

    final parentOffset = parentPost == null ? 0 : 1;
    return ListView.separated(
      controller: controller,
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      itemCount: comments.length + parentOffset,
      separatorBuilder: (context, index) {
        return const SizedBox(height: AppSpacing.md);
      },
      itemBuilder: (context, index) {
        if (parentPost != null && index == 0) {
          return _ParentPostCard(post: parentPost!);
        }
        final comment = comments[index - parentOffset];
        return CommentTile(
          comment: comment,
          isHighlighted: comment.id == highlightedCommentId,
          onLongPress: () => onCommentLongPress(comment),
        );
      },
    );
  }
}

class _ParentPostCard extends StatelessWidget {
  const _ParentPostCard({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    final colors = context.circleColors;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.post,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            post.username,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            post.text,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${post.likesCount} ${AppStrings.like} - '
            '${post.commentsCount} ${AppStrings.comment}',
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: colors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _SmartReplySuggestions extends StatelessWidget {
  const _SmartReplySuggestions({
    required this.state,
    required this.onSelected,
    required this.onDismiss,
    required this.onRetry,
  });

  final AsyncValue<List<String>> state;
  final ValueChanged<String> onSelected;
  final VoidCallback onDismiss;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return state.when(
      data: (items) {
        if (items.isEmpty) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        AppStrings.smartReply,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    IconButton(
                      tooltip: AppStrings.close,
                      onPressed: onDismiss,
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final item in items)
                      ActionChip(
                        label: Text(item),
                        onPressed: () => onSelected(item),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.md),
        child: LinearProgressIndicator(),
      ),
      error: (error, stackTrace) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppErrorBanner(message: error.toString()),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onRetry,
                child: const Text(AppStrings.retry),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentComposer extends StatelessWidget {
  const _CommentComposer({
    required this.controller,
    required this.focusNode,
    required this.formKey,
    required this.isLoading,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final GlobalKey<FormState> formKey;
  final bool isLoading;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final colors = context.circleColors;

    return GlassCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Form(
        key: formKey,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                focusNode: focusNode,
                maxLength: AppLimits.commentTextMaxChars,
                validator: (value) {
                  return Validators.requiredMaxLength(
                    value,
                    AppLimits.commentTextMaxChars,
                  );
                },
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.newline,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: colors.textPrimary),
                decoration: const InputDecoration(
                  hintText: AppStrings.writeComment,
                  helperText: AppStrings.smartReplyHint,
                  counterText: '',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              tooltip: AppStrings.comment,
              onPressed: isLoading ? null : onSubmit,
              icon: isLoading
                  ? const SizedBox.square(
                      dimension: AppSizes.buttonLoader,
                      child: CircularProgressIndicator(
                        strokeWidth: AppSizes.buttonLoaderStroke,
                      ),
                    )
                  : const Icon(Icons.send_outlined),
            ),
          ],
        ),
      ),
    );
  }
}
