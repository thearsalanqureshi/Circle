import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_repository_provider.dart';
import '../../domain/usecases/toggle_post_like.dart';
import 'post_repository_provider.dart';

class OptimisticLikeState {
  const OptimisticLikeState({
    required this.isLiked,
    required this.likesCount,
    required this.isPending,
  });

  final bool isLiked;
  final int likesCount;
  final bool isPending;

  OptimisticLikeState copyWith({bool? isPending}) {
    return OptimisticLikeState(
      isLiked: isLiked,
      likesCount: likesCount,
      isPending: isPending ?? this.isPending,
    );
  }
}

final optimisticLikeControllerProvider = NotifierProvider.autoDispose
    .family<OptimisticLikeController, OptimisticLikeState?, String>(
      OptimisticLikeController.new,
    );

class OptimisticLikeController extends Notifier<OptimisticLikeState?> {
  OptimisticLikeController(this._postId);

  final String _postId;

  @override
  OptimisticLikeState? build() {
    return null;
  }

  Future<bool> toggle({
    required bool baseLiked,
    required int baseLikesCount,
  }) async {
    if (state != null) {
      debugPrint('Like toggle ignored while syncing: postId=$_postId');
      return true;
    }

    final user = ref.read(currentUserProvider);
    if (user == null) {
      return false;
    }

    final currentLiked = state?.isLiked ?? baseLiked;
    final nextLiked = !currentLiked;
    final targetLikesCount = (baseLikesCount + (nextLiked ? 1 : -1))
        .clamp(0, 1 << 31)
        .toInt();

    state = OptimisticLikeState(
      isLiked: nextLiked,
      likesCount: targetLikesCount,
      isPending: true,
    );
    debugPrint(
      'Like optimistic update: postId=$_postId, liked=$nextLiked, '
      'targetLikesCount=$targetLikesCount',
    );

    try {
      await TogglePostLike(ref.read(postRepositoryProvider))(
        postId: _postId,
        userId: user.id,
      );
      state = state?.copyWith(isPending: false);
      debugPrint('Like sync success: postId=$_postId');
      return true;
    } catch (error, stackTrace) {
      debugPrint('Like sync failed: postId=$_postId, error=$error');
      debugPrintStack(stackTrace: stackTrace, label: 'Like sync stack');
      state = null;
      return false;
    }
  }

  void syncWithBackend({
    required bool backendLiked,
    required int backendLikesCount,
  }) {
    final current = state;
    if (current == null || current.isPending) {
      return;
    }

    if (current.isLiked == backendLiked &&
        current.likesCount == backendLikesCount) {
      debugPrint('Like optimistic state cleared: postId=$_postId');
      state = null;
      return;
    }

    debugPrint(
      'Like backend snapshot ignored: postId=$_postId, '
      'liked=$backendLiked/${current.isLiked}, '
      'likes=$backendLikesCount/${current.likesCount}',
    );
  }
}
