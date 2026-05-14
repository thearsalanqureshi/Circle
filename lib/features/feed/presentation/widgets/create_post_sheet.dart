import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_limits.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/utils/backend_error_mapper.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_error_banner.dart';
import '../../../../core/widgets/app_gradient_button.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/services/ai_service.dart';
import '../../../ai_studio/presentation/providers/improve_post_controller.dart';
import '../../../ai_studio/presentation/providers/mood_post_controller.dart';
import '../../../ai_studio/presentation/providers/tone_variants_controller.dart';
import '../../../posts/domain/entities/selected_post_image.dart';
import '../../../posts/presentation/providers/create_post_controller.dart';
import '../../../posts/presentation/providers/selected_post_image_controller.dart';

Future<void> showCreatePostSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.transparent,
    builder: (context) => const CreatePostSheet(),
  );
}

class CreatePostSheet extends ConsumerStatefulWidget {
  const CreatePostSheet({super.key});

  @override
  ConsumerState<CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends ConsumerState<CreatePostSheet> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  final _moodController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    _moodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.viewInsetsOf(context).bottom;
    final createState = ref.watch(createPostControllerProvider);
    final selectedImage = ref.watch(selectedPostImageControllerProvider);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          inset + AppSpacing.lg,
        ),
        child: GlassCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _CreatePostHeader(),
                  const SizedBox(height: AppSpacing.lg),
                  _PostTextField(controller: _textController),
                  const SizedBox(height: AppSpacing.md),
                  _CreatePostAiTools(
                    draftController: _textController,
                    moodController: _moodController,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _SelectedImagePreview(
                    selectedImage: selectedImage,
                    onRemove: () {
                      ref
                          .read(selectedPostImageControllerProvider.notifier)
                          .clear();
                    },
                  ),
                  if (selectedImage.hasError) ...[
                    const SizedBox(height: AppSpacing.md),
                    AppErrorBanner(
                      message: BackendErrorMapper.messageFor(
                        selectedImage.error!,
                        AppStrings.imageTooLarge,
                      ),
                    ),
                  ],
                  if (createState.hasError) ...[
                    const SizedBox(height: AppSpacing.md),
                    AppErrorBanner(
                      message: BackendErrorMapper.messageFor(
                        createState.error!,
                        AppStrings.postCreateFailed,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  _CreatePostActions(
                    isPickingImage: selectedImage.isLoading,
                    isCreatingPost: createState.isLoading,
                    onPickImage: () {
                      ref
                          .read(selectedPostImageControllerProvider.notifier)
                          .pickImage();
                    },
                    onCreatePost: _createPost,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _createPost() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    final image = ref.read(selectedPostImageControllerProvider).asData?.value;
    final created = await ref
        .read(createPostControllerProvider.notifier)
        .createPost(text: _textController.text, image: image);

    if (!created || !mounted) {
      return;
    }

    ref.read(selectedPostImageControllerProvider.notifier).clear();
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger.showSnackBar(
      const SnackBar(content: Text(AppStrings.postCreated)),
    );
  }
}

class _CreatePostAiTools extends ConsumerWidget {
  const _CreatePostAiTools({
    required this.draftController,
    required this.moodController,
  });

  final TextEditingController draftController;
  final TextEditingController moodController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moodState = ref.watch(moodPostControllerProvider);
    final improveState = ref.watch(improvePostControllerProvider);
    final toneState = ref.watch(toneVariantsControllerProvider);
    final isAiBusy =
        moodState.isLoading || improveState.isLoading || toneState.isLoading;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: context.circleColors.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppStrings.aiStudio,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              AppStrings.improveWithAi,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: moodController,
              maxLength: AppLimits.aiMoodMaxChars,
              decoration: const InputDecoration(
                hintText: AppStrings.moodHint,
                counterText: '',
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                FilledButton.icon(
                  onPressed: isAiBusy
                      ? null
                      : () {
                          ref
                              .read(improvePostControllerProvider.notifier)
                              .improve(draftController.text);
                        },
                  icon: improveState.isLoading
                      ? const _MiniLoader()
                      : const Icon(Icons.auto_awesome_outlined),
                  label: const Text(AppStrings.improveMyPost),
                ),
                OutlinedButton.icon(
                  onPressed: isAiBusy
                      ? null
                      : () {
                          ref
                              .read(moodPostControllerProvider.notifier)
                              .generate(moodController.text);
                        },
                  icon: moodState.isLoading
                      ? const _MiniLoader()
                      : const Icon(Icons.mood_outlined),
                  label: const Text(AppStrings.moodToPost),
                ),
                OutlinedButton.icon(
                  onPressed: isAiBusy
                      ? null
                      : () {
                          ref
                              .read(toneVariantsControllerProvider.notifier)
                              .generate(draftController.text);
                        },
                  icon: toneState.isLoading
                      ? const _MiniLoader()
                      : const Icon(Icons.tune_outlined),
                  label: const Text(AppStrings.rewriteChangeTone),
                ),
              ],
            ),
            _ImprovePostResult(
              state: improveState,
              onUse: (text) {
                draftController.text = text;
              },
              onRetry: () {
                ref
                    .read(improvePostControllerProvider.notifier)
                    .improve(draftController.text);
              },
            ),
            _MoodPostResult(
              state: moodState,
              onUse: (text) {
                draftController.text = text;
              },
              onRetry: () {
                ref
                    .read(moodPostControllerProvider.notifier)
                    .generate(moodController.text);
              },
            ),
            _ToneVariantResults(
              state: toneState,
              onUse: (text) {
                draftController.text = text;
              },
              onRetry: () {
                ref
                    .read(toneVariantsControllerProvider.notifier)
                    .generate(draftController.text);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ImprovePostResult extends StatelessWidget {
  const _ImprovePostResult({
    required this.state,
    required this.onUse,
    required this.onRetry,
  });

  final AsyncValue<String?> state;
  final ValueChanged<String> onUse;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return state.when(
      data: (text) {
        if (text == null || text.isEmpty) {
          return const SizedBox.shrink();
        }
        return _AiInlineResult(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(text),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => onUse(text),
                  child: const Text(AppStrings.useImproved),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const _AiInlineLoading(),
      error: (error, stackTrace) =>
          _AiInlineError(error: error, onRetry: onRetry),
    );
  }
}

class _MoodPostResult extends StatelessWidget {
  const _MoodPostResult({
    required this.state,
    required this.onUse,
    required this.onRetry,
  });

  final AsyncValue<String?> state;
  final ValueChanged<String> onUse;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return state.when(
      data: (text) {
        if (text == null || text.isEmpty) {
          return const SizedBox.shrink();
        }
        return _AiInlineResult(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(text),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => onUse(text),
                  child: const Text(AppStrings.useGenerated),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const _AiInlineLoading(),
      error: (error, stackTrace) =>
          _AiInlineError(error: error, onRetry: onRetry),
    );
  }
}

class _ToneVariantResults extends StatelessWidget {
  const _ToneVariantResults({
    required this.state,
    required this.onUse,
    required this.onRetry,
  });

  final AsyncValue<List<AiToneVariant>> state;
  final ValueChanged<String> onUse;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return state.when(
      data: (variants) {
        if (variants.isEmpty) {
          return const SizedBox.shrink();
        }
        return _AiInlineResult(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final variant in variants)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: OutlinedButton(
                    onPressed: () => onUse(variant.text),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${variant.tone}: ${variant.text}',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
      loading: () => const _AiInlineLoading(),
      error: (error, stackTrace) =>
          _AiInlineError(error: error, onRetry: onRetry),
    );
  }
}

class _AiInlineResult extends StatelessWidget {
  const _AiInlineResult({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: child,
    );
  }
}

class _AiInlineLoading extends StatelessWidget {
  const _AiInlineLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: AppSpacing.md),
      child: LinearProgressIndicator(),
    );
  }
}

class _AiInlineError extends StatelessWidget {
  const _AiInlineError({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
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
    );
  }
}

class _MiniLoader extends StatelessWidget {
  const _MiniLoader();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.square(
      dimension: AppSizes.checkIcon,
      child: CircularProgressIndicator(
        strokeWidth: AppSizes.buttonLoaderStroke,
      ),
    );
  }
}

class _CreatePostHeader extends StatelessWidget {
  const _CreatePostHeader();

  @override
  Widget build(BuildContext context) {
    final colors = context.circleColors;

    return Row(
      children: [
        Expanded(
          child: Text(
            AppStrings.newPost,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        IconButton(
          tooltip: AppStrings.close,
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }
}

class _PostTextField extends StatelessWidget {
  const _PostTextField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.circleColors;

    return TextFormField(
      controller: controller,
      minLines: 4,
      maxLines: 8,
      maxLength: AppLimits.postTextMaxChars,
      textInputAction: TextInputAction.newline,
      validator: (value) {
        return Validators.requiredMaxLength(value, AppLimits.postTextMaxChars);
      },
      style: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(color: colors.textPrimary),
      decoration: const InputDecoration(
        hintText: AppStrings.postTextHint,
        counterText: '',
      ),
    );
  }
}

class _SelectedImagePreview extends StatelessWidget {
  const _SelectedImagePreview({
    required this.selectedImage,
    required this.onRemove,
  });

  final AsyncValue<SelectedPostImage?> selectedImage;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final image = selectedImage.asData?.value;
    if (image == null) {
      return const SizedBox.shrink();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: AppSizes.postImageMaxHeight,
        ),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Image.memory(
              image.bytes,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xs),
              child: IconButton.filled(
                tooltip: AppStrings.removeImage,
                onPressed: onRemove,
                icon: const Icon(Icons.close),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreatePostActions extends StatelessWidget {
  const _CreatePostActions({
    required this.isPickingImage,
    required this.isCreatingPost,
    required this.onPickImage,
    required this.onCreatePost,
  });

  final bool isPickingImage;
  final bool isCreatingPost;
  final VoidCallback onPickImage;
  final VoidCallback onCreatePost;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          onPressed: isCreatingPost || isPickingImage ? null : onPickImage,
          icon: isPickingImage
              ? const SizedBox.square(
                  dimension: AppSizes.buttonLoader,
                  child: CircularProgressIndicator(
                    strokeWidth: AppSizes.buttonLoaderStroke,
                  ),
                )
              : const Icon(Icons.image_outlined),
          label: const Text(AppStrings.addImage),
        ),
        const SizedBox(height: AppSpacing.md),
        AppGradientButton(
          label: AppStrings.post,
          isLoading: isCreatingPost,
          onPressed: onCreatePost,
        ),
      ],
    );
  }
}
