import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_limits.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/services/ai_service.dart';
import '../../../../core/widgets/app_error_banner.dart';
import '../../../../core/widgets/app_gradient_button.dart';
import '../../../../core/widgets/app_screen_layout.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../posts/presentation/providers/post_repository_provider.dart';
import '../providers/feed_summary_controller.dart';
import '../providers/mood_post_controller.dart';
import '../providers/tone_variants_controller.dart';

class AiStudioScreen extends ConsumerStatefulWidget {
  const AiStudioScreen({super.key});

  @override
  ConsumerState<AiStudioScreen> createState() => _AiStudioScreenState();
}

class _AiStudioScreenState extends ConsumerState<AiStudioScreen> {
  final _moodController = TextEditingController();
  final _toneController = TextEditingController();

  @override
  void dispose() {
    _moodController.dispose();
    _toneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final posts = ref.watch(visibleFeedPostsProvider).asData?.value ?? const [];
    final postTexts = posts
        .map((post) => post.text)
        .where((text) => text.trim().isNotEmpty)
        .take(AppLimits.aiFeedSummaryPostCount)
        .toList();

    return AppScreenLayout(
      title: AppStrings.aiStudio,
      child: ListView(
        key: const PageStorageKey<String>(AppRoutes.aiStudio),
        padding: const EdgeInsets.only(
          bottom: AppSizes.shellScrollBottomPadding,
        ),
        children: [
          Text(
            AppStrings.aiStudioEmptyBody,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            AppStrings.aiInlineWritingTip,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          _MoodPostCard(controller: _moodController),
          const SizedBox(height: AppSpacing.md),
          _ToneTransformerCard(controller: _toneController),
          const SizedBox(height: AppSpacing.md),
          _FeedSummaryCard(postTexts: postTexts),
          const SizedBox(height: AppSpacing.md),
          const _SmartReplyCard(),
        ],
      ),
    );
  }
}

class _MoodPostCard extends ConsumerWidget {
  const _MoodPostCard({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(moodPostControllerProvider);

    return _AiCard(
      icon: Icons.mood_outlined,
      title: AppStrings.moodToPost,
      body: AppStrings.aiGenerateFromMood,
      children: [
        _AiInput(
          controller: controller,
          hintText: AppStrings.moodHint,
          maxLength: AppLimits.aiMoodMaxChars,
        ),
        const SizedBox(height: AppSpacing.sm),
        _AiRunButton(
          label: AppStrings.generatePost,
          isLoading: state.isLoading,
          onPressed: () {
            ref
                .read(moodPostControllerProvider.notifier)
                .generate(controller.text);
          },
        ),
        _AiResultText(
          state: state,
          onRetry: () {
            ref
                .read(moodPostControllerProvider.notifier)
                .generate(controller.text);
          },
        ),
      ],
    );
  }
}

class _ToneTransformerCard extends ConsumerWidget {
  const _ToneTransformerCard({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(toneVariantsControllerProvider);

    return _AiCard(
      icon: Icons.tune_outlined,
      title: AppStrings.toneTransformer,
      body: AppStrings.aiRewriteDraft,
      children: [
        _AiInput(
          controller: controller,
          hintText: AppStrings.draftHint,
          maxLength: AppLimits.aiDraftMaxChars,
          maxLines: 4,
        ),
        const SizedBox(height: AppSpacing.sm),
        _AiRunButton(
          label: AppStrings.transformTone,
          isLoading: state.isLoading,
          onPressed: () {
            ref
                .read(toneVariantsControllerProvider.notifier)
                .generate(controller.text);
          },
        ),
        _ToneResults(
          state: state,
          onRetry: () {
            ref
                .read(toneVariantsControllerProvider.notifier)
                .generate(controller.text);
          },
        ),
      ],
    );
  }
}

class _FeedSummaryCard extends ConsumerWidget {
  const _FeedSummaryCard({required this.postTexts});

  final List<String> postTexts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(feedSummaryControllerProvider);

    return _AiCard(
      icon: Icons.summarize_outlined,
      title: AppStrings.feedSummarizer,
      body: AppStrings.aiSummarizeFeed,
      children: [
        _AiRunButton(
          label: AppStrings.summarize,
          isLoading: state.isLoading,
          onPressed: postTexts.isEmpty
              ? null
              : () {
                  ref
                      .read(feedSummaryControllerProvider.notifier)
                      .summarize(postTexts);
                },
        ),
        if (postTexts.isEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            AppStrings.aiNoFeedPosts,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        _SummaryResults(
          state: state,
          onRetry: postTexts.isEmpty
              ? null
              : () {
                  ref
                      .read(feedSummaryControllerProvider.notifier)
                      .summarize(postTexts);
                },
        ),
      ],
    );
  }
}

class _SmartReplyCard extends StatelessWidget {
  const _SmartReplyCard();

  @override
  Widget build(BuildContext context) {
    return const _AiCard(
      icon: Icons.quickreply_outlined,
      title: AppStrings.smartReply,
      body: AppStrings.aiReplyToComment,
      children: [],
    );
  }
}

class _AiCard extends StatelessWidget {
  const _AiCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.children,
  });

  final IconData icon;
  final String title;
  final String body;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.circleColors;

    return GlassCard(
      isHighlighted: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            body,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colors.textSecondary),
          ),
          if (children.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            ...children,
          ],
        ],
      ),
    );
  }
}

class _AiInput extends StatelessWidget {
  const _AiInput({
    required this.controller,
    required this.hintText,
    required this.maxLength,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String hintText;
  final int maxLength;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLength: maxLength,
      maxLines: maxLines,
      decoration: InputDecoration(hintText: hintText, counterText: ''),
    );
  }
}

class _AiRunButton extends StatelessWidget {
  const _AiRunButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return AppGradientButton(
      label: label,
      isLoading: isLoading,
      onPressed: isLoading ? null : onPressed,
    );
  }
}

class _AiResultText extends StatelessWidget {
  const _AiResultText({required this.state, required this.onRetry});

  final AsyncValue<String?> state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return state.when(
      data: (text) {
        if (text == null || text.isEmpty) {
          return const SizedBox.shrink();
        }
        return _ResultBlock(child: Text(text));
      },
      loading: () => const _AiLoadingLines(),
      error: (error, stackTrace) => _AiError(error: error, onRetry: onRetry),
    );
  }
}

class _ToneResults extends StatelessWidget {
  const _ToneResults({required this.state, required this.onRetry});

  final AsyncValue<List<AiToneVariant>> state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return state.when(
      data: (variants) {
        if (variants.isEmpty) {
          return const SizedBox.shrink();
        }
        return _ResultBlock(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final variant in variants) ...[
                Text(
                  variant.tone,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(variant.text),
                const SizedBox(height: AppSpacing.sm),
              ],
            ],
          ),
        );
      },
      loading: () => const _AiLoadingLines(),
      error: (error, stackTrace) => _AiError(error: error, onRetry: onRetry),
    );
  }
}

class _SummaryResults extends StatelessWidget {
  const _SummaryResults({required this.state, required this.onRetry});

  final AsyncValue<List<String>> state;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return state.when(
      data: (items) {
        if (items.isEmpty) {
          return const SizedBox.shrink();
        }
        return _ResultBlock(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final item in items)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Text('- $item'),
                ),
            ],
          ),
        );
      },
      loading: () => const _AiLoadingLines(),
      error: (error, stackTrace) => _AiError(error: error, onRetry: onRetry),
    );
  }
}

class _ResultBlock extends StatelessWidget {
  const _ResultBlock({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: child,
    );
  }
}

class _AiLoadingLines extends StatelessWidget {
  const _AiLoadingLines();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: AppSpacing.md),
      child: Column(
        children: [
          _LoadingLine(widthFactor: 1),
          SizedBox(height: AppSpacing.xs),
          _LoadingLine(widthFactor: 0.72),
        ],
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
      alignment: Alignment.centerLeft,
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

class _AiError extends StatelessWidget {
  const _AiError({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppErrorBanner(message: error.toString()),
          if (onRetry != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onRetry,
                child: const Text(AppStrings.retry),
              ),
            ),
        ],
      ),
    );
  }
}
