import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_repository_provider.dart';
import '../../domain/usecases/toggle_post_like.dart';
import 'post_repository_provider.dart';

final postActionsControllerProvider =
    AsyncNotifierProvider.autoDispose<PostActionsController, void>(
      PostActionsController.new,
    );

class PostActionsController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> toggleLike(String postId) async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      return;
    }

    state = const AsyncLoading();
    try {
      await TogglePostLike(ref.read(postRepositoryProvider))(
        postId: postId,
        userId: user.id,
      );
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}
