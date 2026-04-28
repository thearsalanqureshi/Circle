import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/firebase_paths.dart';
import '../../../profile/domain/entities/user_profile.dart';
import '../../domain/entities/comment.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';
import '../models/comment_model.dart';
import '../models/post_model.dart';

class FirebasePostRepository implements PostRepository {
  const FirebasePostRepository(this._firestore);

  static final _loggedWatchUserPostErrors = <String>{};

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _postsCollection {
    return _firestore.collection(FirebasePaths.posts);
  }

  @override
  Stream<List<Post>> watchFeedPosts({required int limit}) {
    return _postsCollection
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(PostModel.fromSnapshot).toList());
  }

  @override
  Future<List<Post>> fetchFeedPostsPage({
    required int limit,
    DateTime? startAfterCreatedAt,
  }) async {
    Query<Map<String, dynamic>> query = _postsCollection.orderBy(
      'createdAt',
      descending: true,
    );
    if (startAfterCreatedAt != null) {
      query = query.startAfter([Timestamp.fromDate(startAfterCreatedAt)]);
    }

    final snapshot = await query.limit(limit).get();
    debugPrint(
      'FirebasePostRepository.fetchFeedPostsPage: '
      'limit=$limit, startAfter=$startAfterCreatedAt, '
      'count=${snapshot.docs.length}',
    );
    return snapshot.docs.map(PostModel.fromSnapshot).toList();
  }

  @override
  Stream<List<Post>> watchUserPosts({
    required String userId,
    required int limit,
  }) {
    debugPrint(
      'FirebasePostRepository.watchUserPosts: '
      'path=${FirebasePaths.posts}, where userId==$userId, '
      'orderBy=createdAt desc, limit=$limit',
    );
    return _postsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map(PostModel.fromSnapshot).toList();
        })
        .handleError((Object error, StackTrace stackTrace) {
          final key = '$userId:$error';
          if (_loggedWatchUserPostErrors.add(key)) {
            debugPrint(
              'FirebasePostRepository.watchUserPosts failed: '
              'userId=$userId error=$error',
            );
            debugPrintStack(
              stackTrace: stackTrace,
              label: 'watchUserPosts stack',
            );
          }
        });
  }

  @override
  Future<void> createPost({
    required String postId,
    required UserProfile author,
    required String text,
    required String? imageBase64,
  }) async {
    final postReference = _postsCollection.doc(postId);
    final userReference = _firestore.doc(FirebasePaths.user(author.id));
    final trimmedText = text.trim();
    final handle = _handleFor(author);
    final postPath = FirebasePaths.post(postId);

    try {
      await postReference.set(
        PostModel.createMap(
          id: postReference.id,
          userId: author.id,
          username: author.displayName,
          userHandle: handle,
          userPhotoUrl: author.photoUrl,
          text: trimmedText,
          imageBase64: imageBase64,
        ),
      );
      debugPrint('FirebasePostRepository.createPost: wrote $postPath');
    } on FirebaseException catch (error, stackTrace) {
      _logFirestoreError('createPost.postWrite', postPath, error, stackTrace);
      rethrow;
    }

    try {
      await userReference.set({
        'id': author.id,
        'displayName': author.displayName,
        'email': author.email,
        'photoUrl': author.photoUrl,
        'postsCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      debugPrint(
        'FirebasePostRepository.createPost: updated ${FirebasePaths.user(author.id)}',
      );
    } on FirebaseException catch (error, stackTrace) {
      _logFirestoreError(
        'createPost.userCounterUpdate',
        FirebasePaths.user(author.id),
        error,
        stackTrace,
      );
    }
  }

  @override
  Stream<bool> watchIsLiked({required String postId, required String userId}) {
    return _firestore
        .doc(FirebasePaths.postLike(postId, userId))
        .snapshots()
        .map((snapshot) => snapshot.exists);
  }

  @override
  Future<void> toggleLike({
    required String postId,
    required String userId,
  }) async {
    final postReference = _firestore.doc(FirebasePaths.post(postId));
    final likeReference = _firestore.doc(
      FirebasePaths.postLike(postId, userId),
    );

    await _firestore.runTransaction((transaction) async {
      final postSnapshot = await transaction.get(postReference);
      if (!postSnapshot.exists) {
        throw StateError('Post not found.');
      }

      final likeSnapshot = await transaction.get(likeReference);
      final data = postSnapshot.data() ?? {};
      final currentLikes = data['likesCount'] as int? ?? 0;

      if (likeSnapshot.exists) {
        transaction.delete(likeReference);
        transaction.update(postReference, {
          'likesCount': currentLikes > 0 ? currentLikes - 1 : 0,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        return;
      }

      transaction.set(likeReference, {
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      transaction.update(postReference, {
        'likesCount': currentLikes + 1,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Stream<List<Comment>> watchComments({
    required String postId,
    required int limit,
  }) {
    return _postsCollection
        .doc(postId)
        .collection(FirebasePaths.comments)
        .orderBy('createdAt', descending: false)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    CommentModel.fromSnapshot(postId: postId, snapshot: doc),
              )
              .toList(),
        );
  }

  @override
  Future<void> addComment({
    required String postId,
    required UserProfile author,
    required String text,
  }) async {
    final postReference = _firestore.doc(FirebasePaths.post(postId));
    final commentReference = postReference
        .collection(FirebasePaths.comments)
        .doc();
    final trimmedText = text.trim();

    final batch = _firestore.batch();
    batch.set(
      commentReference,
      CommentModel.createMap(
        id: commentReference.id,
        postId: postId,
        userId: author.id,
        username: author.displayName,
        userPhotoUrl: author.photoUrl,
        text: trimmedText,
      ),
    );
    batch.update(postReference, {
      'commentsCount': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  String _handleFor(UserProfile author) {
    final emailName = author.email?.split('@').first;
    final source = emailName?.trim().isNotEmpty == true
        ? emailName!
        : author.displayName;
    final normalized = source.trim().toLowerCase().replaceAll(
      RegExp('[^a-z0-9_]+'),
      '',
    );
    return '@${normalized.isEmpty ? author.id : normalized}';
  }

  void _logFirestoreError(
    String operation,
    String path,
    FirebaseException error,
    StackTrace stackTrace,
  ) {
    debugPrint(
      'FirebasePostRepository.$operation failed: '
      'path=$path, plugin=${error.plugin}, '
      'code=${error.code}, message=${error.message}',
    );
    debugPrintStack(stackTrace: stackTrace, label: '$operation stack');
  }
}
