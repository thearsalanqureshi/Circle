import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_limits.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../auth/presentation/providers/auth_repository_provider.dart';
import '../../../profile/domain/entities/user_profile.dart';
import '../../../profile/presentation/providers/profile_repository_provider.dart';
import '../../../posts/domain/usecases/add_post_comment.dart';
import '../../../posts/presentation/providers/post_repository_provider.dart';

final addCommentControllerProvider =
    AsyncNotifierProvider.autoDispose<AddCommentController, void>(
      AddCommentController.new,
    );

class AddCommentController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> addComment({
    required String postId,
    required String text,
  }) async {
    final trimmedText = text.trim();
    final user = ref.read(currentUserProvider);
    if (user == null || trimmedText.isEmpty) {
      return false;
    }
    if (trimmedText.length > AppLimits.commentTextMaxChars) {
      state = AsyncError(
        AppStrings.validationMaxLength(AppLimits.commentTextMaxChars),
        StackTrace.current,
      );
      return false;
    }

    state = const AsyncLoading();
    try {
      await ref.read(profileRepositoryProvider).ensureUserProfile(user);
      final profile =
          ref.read(currentUserProfileProvider).asData?.value ??
          UserProfile.fromAppUser(user);
      await AddPostComment(ref.read(postRepositoryProvider))(
        postId: postId,
        author: profile,
        text: trimmedText,
      );
      state = const AsyncData(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return false;
    }
  }
}
