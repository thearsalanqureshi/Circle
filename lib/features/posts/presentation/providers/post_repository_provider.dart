import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_limits.dart';
import '../../../../core/constants/hive_keys.dart';
import '../../../../core/providers/firebase_providers.dart';
import '../../../../core/services/hive_bootstrap.dart';
import '../../../auth/presentation/providers/auth_repository_provider.dart';
import '../../data/models/post_model.dart';
import '../../data/repositories/firebase_post_repository.dart';
import '../../domain/entities/comment.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';
import '../../domain/usecases/watch_feed_posts.dart';
import '../../domain/usecases/watch_post_comments.dart';
import '../../domain/usecases/watch_user_posts.dart';

final postRepositoryProvider = Provider<PostRepository>((ref) {
  return FirebasePostRepository(ref.watch(firebaseFirestoreProvider));
});

final feedPostsProvider = StreamProvider<List<Post>>((ref) {
  return WatchFeedPosts(ref.watch(postRepositoryProvider))(
    limit: AppLimits.feedPostsPageSize,
  ).distinct(_samePostList).map((posts) {
    debugPrint('feedPostsProvider update count=${posts.length}');
    return posts;
  });
});

final visibleFeedPostsProvider = Provider<AsyncValue<List<Post>>>((ref) {
  ref.listen<AsyncValue<List<Post>>>(feedPostsProvider, (previous, next) {
    next.whenData((posts) {
      final existing = ref.read(feedPostCacheProvider);
      ref.read(feedPostCacheProvider.notifier).setPosts([
        ...posts,
        ...existing,
      ]);
    });
  });
  final localPosts = ref.watch(localPostOverlayProvider);
  final cachedPosts = ref.watch(feedPostCacheProvider);
  final pagedPosts = ref.watch(
    feedPaginationControllerProvider.select((state) => state.olderPosts),
  );
  final remotePosts = ref.watch(feedPostsProvider);
  final fallbackPosts = _mergeUniquePosts([
    ..._mergeLocalPosts(remotePosts: cachedPosts, localPosts: localPosts),
    ...pagedPosts,
  ]).rankForFeed();
  return remotePosts.when(
    data: (posts) {
      final merged = _mergeUniquePosts([
        ..._mergeLocalPosts(remotePosts: posts, localPosts: localPosts),
        ...cachedPosts,
        ...pagedPosts,
      ]).rankForFeed();
      debugPrint(
        'visibleFeedPostsProvider remote=${posts.length} '
        'local=${localPosts.length} merged=${merged.length}',
      );
      return AsyncData(merged);
    },
    loading: () {
      if (fallbackPosts.isNotEmpty) {
        debugPrint(
          'visibleFeedPostsProvider loading with fallback=${fallbackPosts.length}',
        );
        return AsyncData(fallbackPosts);
      }
      debugPrint('visibleFeedPostsProvider first load');
      return const AsyncLoading();
    },
    error: (error, stackTrace) {
      debugPrint('visibleFeedPostsProvider error=$error');
      if (fallbackPosts.isNotEmpty) {
        debugPrint(
          'visibleFeedPostsProvider using cached fallback '
          'count=${fallbackPosts.length}',
        );
        return AsyncData(fallbackPosts);
      }
      return AsyncError(error, stackTrace);
    },
  );
});

final visibleUserPostsProvider =
    Provider.family<AsyncValue<List<Post>>, String>((ref, userId) {
      ref.listen<AsyncValue<List<Post>>>(userPostsProvider(userId), (
        previous,
        next,
      ) {
        next.whenData((posts) {
          ref.read(userPostCacheProvider.notifier).setPosts(userId, posts);
        });
      });
      final localPosts = ref.watch(localPostOverlayProvider);
      final cachedPosts = ref.watch(
        userPostCacheProvider.select(
          (cache) => cache[userId] ?? const <Post>[],
        ),
      );
      final remotePosts = ref.watch(userPostsProvider(userId));
      final scopedLocalPosts = _filterLocalPosts(
        localPosts: localPosts,
        userId: userId,
      );
      final fallbackPosts = _mergeLocalPosts(
        remotePosts: cachedPosts,
        localPosts: localPosts,
        userId: userId,
      );
      return remotePosts.when(
        data: (posts) {
          final merged = _mergeLocalPosts(
            remotePosts: posts,
            localPosts: localPosts,
            userId: userId,
          );
          debugPrint(
            'visibleUserPostsProvider userId=$userId remote=${posts.length} '
            'local=${scopedLocalPosts.length} merged=${merged.length}',
          );
          return AsyncData(merged);
        },
        loading: () {
          if (fallbackPosts.isNotEmpty) {
            debugPrint(
              'visibleUserPostsProvider userId=$userId loading with '
              'fallback=${fallbackPosts.length}',
            );
            return AsyncData(fallbackPosts);
          }
          debugPrint('visibleUserPostsProvider userId=$userId loading');
          return const AsyncLoading();
        },
        error: (error, stackTrace) {
          debugPrint(
            'visibleUserPostsProvider userId=$userId error=$error '
            'local=${scopedLocalPosts.length}',
          );
          if (fallbackPosts.isNotEmpty) {
            debugPrint(
              'visibleUserPostsProvider userId=$userId using cached fallback '
              'count=${fallbackPosts.length}',
            );
            return AsyncData(fallbackPosts);
          }
          return AsyncError(error, stackTrace);
        },
      );
    });

final postByIdProvider = Provider.family<Post?, String>((ref, postId) {
  final visiblePosts =
      ref.watch(visibleFeedPostsProvider).asData?.value ?? const <Post>[];
  final cachedPosts = ref.watch(feedPostCacheProvider);
  final localPosts = ref.watch(localPostOverlayProvider);

  for (final post in [...localPosts, ...visiblePosts, ...cachedPosts]) {
    if (post.id == postId) {
      return post;
    }
  }
  return null;
});

final localPostOverlayProvider =
    NotifierProvider<LocalPostOverlayController, List<Post>>(
      LocalPostOverlayController.new,
    );

final feedPostCacheProvider =
    NotifierProvider<FeedPostCacheController, List<Post>>(
      FeedPostCacheController.new,
    );

final feedPaginationControllerProvider =
    NotifierProvider<FeedPaginationController, FeedPaginationState>(
      FeedPaginationController.new,
    );

final userPostCacheProvider =
    NotifierProvider<UserPostCacheController, Map<String, List<Post>>>(
      UserPostCacheController.new,
    );

class FeedPostCacheController extends Notifier<List<Post>> {
  @override
  List<Post> build() {
    final cached = HiveBootstrap.feedPostsCacheBox.get(HiveKeys.feedPosts);
    if (cached is! List) {
      return const [];
    }
    final posts = <Post>[];
    for (final item in cached) {
      if (item is Map) {
        posts.add(PostModel.fromCacheMap(Map<String, dynamic>.from(item)));
      }
    }
    debugPrint('feedPostCacheProvider loaded count=${posts.length}');
    return posts;
  }

  void setPosts(List<Post> posts) {
    final next = _limitCachePosts(_mergeUniquePosts(posts));
    if (_samePostList(state, next)) {
      return;
    }
    state = next;
    _persist();
    debugPrint('feedPostCacheProvider set count=${next.length}');
  }

  void upsert(Post post) {
    state = _limitCachePosts([
      post,
      for (final existing in state)
        if (existing.id != post.id) existing,
    ]);
    _persist();
    debugPrint(
      'feedPostCacheProvider upsert postId=${post.id} count=${state.length}',
    );
  }

  void appendOlder(List<Post> posts) {
    if (posts.isEmpty) {
      return;
    }
    setPosts([...state, ...posts]);
  }

  void _persist() {
    final cached = state.map(PostModel.toCacheMap).toList(growable: false);
    HiveBootstrap.feedPostsCacheBox.put(HiveKeys.feedPosts, cached);
  }
}

class FeedPaginationState {
  const FeedPaginationState({
    required this.olderPosts,
    required this.isLoading,
    required this.hasMore,
    required this.error,
  });

  const FeedPaginationState.initial()
    : olderPosts = const [],
      isLoading = false,
      hasMore = true,
      error = null;

  final List<Post> olderPosts;
  final bool isLoading;
  final bool hasMore;
  final Object? error;

  FeedPaginationState copyWith({
    List<Post>? olderPosts,
    bool? isLoading,
    bool? hasMore,
    Object? error,
    bool clearError = false,
  }) {
    return FeedPaginationState(
      olderPosts: olderPosts ?? this.olderPosts,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class FeedPaginationController extends Notifier<FeedPaginationState> {
  @override
  FeedPaginationState build() {
    return const FeedPaginationState.initial();
  }

  Future<void> loadNextPage({required List<Post> currentPosts}) async {
    if (state.isLoading || !state.hasMore || currentPosts.isEmpty) {
      return;
    }

    final cursor = _oldestCreatedAt(currentPosts);
    if (cursor == null) {
      state = state.copyWith(hasMore: false, clearError: true);
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final fetched = await ref
          .read(postRepositoryProvider)
          .fetchFeedPostsPage(
            limit: AppLimits.feedPostsPageSize,
            startAfterCreatedAt: cursor,
          );
      final existingIds = currentPosts.map((post) => post.id).toSet();
      final olderIds = state.olderPosts.map((post) => post.id).toSet();
      final nextPosts = [
        for (final post in fetched)
          if (!existingIds.contains(post.id) && olderIds.add(post.id)) post,
      ];
      final olderPosts = _mergeUniquePosts([...state.olderPosts, ...nextPosts]);
      state = state.copyWith(
        olderPosts: olderPosts,
        isLoading: false,
        hasMore: fetched.length == AppLimits.feedPostsPageSize,
        clearError: true,
      );
      ref.read(feedPostCacheProvider.notifier).setPosts([
        ...currentPosts,
        ...olderPosts,
      ]);
      debugPrint(
        'FeedPaginationController loaded fetched=${fetched.length} '
        'added=${nextPosts.length} totalOlder=${olderPosts.length}',
      );
    } catch (error, stackTrace) {
      debugPrint('FeedPaginationController failed: $error');
      debugPrintStack(stackTrace: stackTrace, label: 'Feed pagination stack');
      state = state.copyWith(isLoading: false, error: error);
    }
  }

  void reset() {
    state = const FeedPaginationState.initial();
  }
}

class UserPostCacheController extends Notifier<Map<String, List<Post>>> {
  @override
  Map<String, List<Post>> build() {
    return const {};
  }

  void setPosts(String userId, List<Post> posts) {
    if (_samePostList(state[userId] ?? const <Post>[], posts)) {
      return;
    }
    state = {...state, userId: posts};
    debugPrint(
      'userPostCacheProvider set userId=$userId count=${posts.length}',
    );
  }

  void upsert(Post post) {
    final current = state[post.userId] ?? const <Post>[];
    final next = [
      post,
      for (final existing in current)
        if (existing.id != post.id) existing,
    ];
    state = {...state, post.userId: next};
    debugPrint(
      'userPostCacheProvider upsert userId=${post.userId} '
      'postId=${post.id} count=${next.length}',
    );
  }
}

class LocalPostOverlayController extends Notifier<List<Post>> {
  @override
  List<Post> build() {
    return const [];
  }

  void add(Post post) {
    if (state.any((existing) => existing.id == post.id)) {
      return;
    }
    state = [post, ...state];
    debugPrint('localPostOverlayProvider add postId=${post.id}');
  }

  void remove(String postId) {
    state = [
      for (final post in state)
        if (post.id != postId) post,
    ];
    debugPrint('localPostOverlayProvider remove postId=$postId');
  }
}

List<Post> _limitCachePosts(List<Post> posts) {
  return posts.take(AppLimits.feedPostsCacheSize).toList(growable: false);
}

List<Post> _mergeUniquePosts(List<Post> posts) {
  final seen = <String>{};
  return [
    for (final post in posts)
      if (seen.add(post.id)) post,
  ];
}

extension _FeedRanking on List<Post> {
  List<Post> rankForFeed() {
    final ranked = [...this];
    ranked.sort((a, b) => _feedScore(b).compareTo(_feedScore(a)));
    return ranked;
  }
}

int _feedScore(Post post) {
  final createdAt =
      post.createdAt?.millisecondsSinceEpoch ??
      DateTime.fromMillisecondsSinceEpoch(0).millisecondsSinceEpoch;
  final engagementMinutes = (post.likesCount * 2 + post.commentsCount * 3)
      .clamp(0, 30)
      .toInt();
  return createdAt + Duration(minutes: engagementMinutes).inMilliseconds;
}

DateTime? _oldestCreatedAt(List<Post> posts) {
  DateTime? oldest;
  for (final post in posts) {
    final createdAt = post.createdAt;
    if (createdAt == null) {
      continue;
    }
    if (oldest == null || createdAt.isBefore(oldest)) {
      oldest = createdAt;
    }
  }
  return oldest;
}

List<Post> _mergeLocalPosts({
  required List<Post> remotePosts,
  required List<Post> localPosts,
  String? userId,
}) {
  final remoteIds = remotePosts.map((post) => post.id).toSet();
  final filteredLocalPosts =
      _filterLocalPosts(localPosts: localPosts, userId: userId).where((post) {
        if (remoteIds.contains(post.id)) {
          return false;
        }
        return true;
      });
  return [...filteredLocalPosts, ...remotePosts];
}

List<Post> _filterLocalPosts({required List<Post> localPosts, String? userId}) {
  if (userId == null) {
    return localPosts;
  }
  return [
    for (final post in localPosts)
      if (post.userId == userId) post,
  ];
}

bool _samePostList(List<Post> previous, List<Post> next) {
  if (identical(previous, next)) {
    return true;
  }
  if (previous.length != next.length) {
    return false;
  }
  for (var index = 0; index < previous.length; index += 1) {
    if (!_samePost(previous[index], next[index])) {
      return false;
    }
  }
  return true;
}

bool _samePost(Post previous, Post next) {
  return previous.id == next.id &&
      previous.userId == next.userId &&
      previous.username == next.username &&
      previous.userHandle == next.userHandle &&
      previous.userPhotoUrl == next.userPhotoUrl &&
      previous.text == next.text &&
      previous.imageBase64 == next.imageBase64 &&
      previous.imageUrl == next.imageUrl &&
      previous.imagePath == next.imagePath &&
      previous.likesCount == next.likesCount &&
      previous.commentsCount == next.commentsCount &&
      previous.sharesCount == next.sharesCount &&
      previous.createdAt == next.createdAt &&
      previous.updatedAt == next.updatedAt;
}

final userPostsProvider = StreamProvider.family<List<Post>, String>((
  ref,
  userId,
) {
  return WatchUserPosts(ref.watch(postRepositoryProvider))(
    userId: userId,
    limit: AppLimits.profilePostsPageSize,
  ).distinct(_samePostList).map((posts) {
    debugPrint('userPostsProvider update userId=$userId count=${posts.length}');
    return posts;
  });
});

final postLikedProvider = StreamProvider.family<bool, String>((ref, postId) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return Stream<bool>.value(false);
  }
  return ref
      .watch(postRepositoryProvider)
      .watchIsLiked(postId: postId, userId: user.id);
});

final postCommentsProvider = StreamProvider.family<List<Comment>, String>((
  ref,
  postId,
) {
  return WatchPostComments(ref.watch(postRepositoryProvider))(
    postId: postId,
    limit: AppLimits.commentsPageSize,
  );
});
