import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_repository_provider.dart';
import '../../../profile/domain/entities/user_profile.dart';
import '../../../profile/presentation/providers/profile_repository_provider.dart';
import '../../domain/entities/selected_post_image.dart';
import '../../domain/usecases/create_post.dart';
import 'post_repository_provider.dart';

final createPostControllerProvider =
    AsyncNotifierProvider.autoDispose<CreatePostController, void>(
      CreatePostController.new,
    );

class CreatePostController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> createPost({
    required String text,
    SelectedPostImage? image,
  }) async {
    final trimmedText = text.trim();
    final user = ref.read(currentUserProvider);
    if (user == null || trimmedText.isEmpty) {
      debugPrint(
        'CreatePostController: aborted. '
        'uid=${user?.id}, textEmpty=${trimmedText.isEmpty}',
      );
      return false;
    }

    state = const AsyncLoading();
    try {
      final profile =
          ref.read(currentUserProfileProvider).asData?.value ??
          UserProfile.fromAppUser(user);
      debugPrint(
        'CreatePostController: creating post for uid=${user.id}, '
        'hasImage=${image != null}',
      );
      final createdPost = await CreatePost(
        postRepository: ref.read(postRepositoryProvider),
      )(author: profile, text: trimmedText, image: image);
      ref.read(localPostOverlayProvider.notifier).add(createdPost);
      ref.read(feedPostCacheProvider.notifier).upsert(createdPost);
      ref.read(userPostCacheProvider.notifier).upsert(createdPost);
      debugPrint(
        'CreatePostController: created postId=${createdPost.id}, '
        'userId=${createdPost.userId}; refreshing profile posts stream',
      );
      ref.invalidate(userPostsProvider(createdPost.userId));
      state = const AsyncData(null);
      return true;
    } catch (error, stackTrace) {
      _logPostCreationError(error, stackTrace);
      state = AsyncError(error, stackTrace);
      return false;
    }
  }

  void _logPostCreationError(Object error, StackTrace stackTrace) {
    if (error is FirebaseException) {
      debugPrint(
        'CreatePostController FirebaseException: '
        'plugin=${error.plugin}, code=${error.code}, '
        'message=${error.message}, details=${error.stackTrace}',
      );
    } else {
      debugPrint('CreatePostController error: $error');
    }
    debugPrintStack(stackTrace: stackTrace, label: 'Create post stack');
  }
}
