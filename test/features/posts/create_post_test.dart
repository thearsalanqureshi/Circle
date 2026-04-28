import 'dart:convert';
import 'dart:typed_data';

import 'package:circle/core/errors/image_too_large_exception.dart';
import 'package:circle/features/posts/domain/entities/comment.dart';
import 'package:circle/features/posts/domain/entities/post.dart';
import 'package:circle/features/posts/domain/entities/selected_post_image.dart';
import 'package:circle/features/posts/domain/repositories/post_repository.dart';
import 'package:circle/features/posts/domain/usecases/create_post.dart';
import 'package:circle/features/profile/domain/entities/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CreatePost', () {
    test('creates text posts without image data', () async {
      final postRepository = _FakePostRepository();
      final useCase = CreatePost(postRepository: postRepository);

      await useCase(author: _author, text: 'Hello Circle');

      expect(postRepository.createdText, 'Hello Circle');
      expect(postRepository.createdImageBase64, isNull);
    });

    test('encodes compressed image bytes before creating image post', () async {
      final postRepository = _FakePostRepository();
      final useCase = CreatePost(postRepository: postRepository);
      final image = SelectedPostImage(
        bytes: Uint8List.fromList([1, 2, 3]),
        fileName: 'post.jpg',
        contentType: 'image/jpeg',
      );

      await useCase(author: _author, text: 'Image post', image: image);

      expect(postRepository.createdImageBase64, base64Encode(image.bytes));
      expect(base64Decode(postRepository.createdImageBase64!), image.bytes);
    });

    test('rejects compressed image bytes above the Firestore safety limit', () {
      final postRepository = _FakePostRepository();
      final useCase = CreatePost(postRepository: postRepository);
      final image = SelectedPostImage(
        bytes: Uint8List(300 * 1024 + 1),
        fileName: 'large.jpg',
        contentType: 'image/jpeg',
      );

      expect(
        useCase(author: _author, text: 'Large image', image: image),
        throwsA(isA<ImageTooLargeException>()),
      );
    });
  });
}

const _author = UserProfile(
  id: 'u1',
  displayName: 'Maya Chen',
  email: 'maya@example.com',
  photoUrl: null,
  bio: '',
  postsCount: 0,
  followersCount: 0,
  followingCount: 0,
  createdAt: null,
  updatedAt: null,
);

class _FakePostRepository implements PostRepository {
  String? createdPostId;
  String? createdText;
  String? createdImageBase64;

  @override
  Future<void> createPost({
    required String postId,
    required UserProfile author,
    required String text,
    required String? imageBase64,
  }) async {
    createdPostId = postId;
    createdText = text;
    createdImageBase64 = imageBase64;
  }

  @override
  Future<void> addComment({
    required String postId,
    required UserProfile author,
    required String text,
  }) async {}

  @override
  Future<void> toggleLike({required String postId, required String userId}) {
    throw UnimplementedError();
  }

  @override
  Stream<List<Comment>> watchComments({
    required String postId,
    required int limit,
  }) {
    return const Stream.empty();
  }

  @override
  Stream<List<Post>> watchFeedPosts({required int limit}) {
    return const Stream.empty();
  }

  @override
  Future<List<Post>> fetchFeedPostsPage({
    required int limit,
    DateTime? startAfterCreatedAt,
  }) async {
    return const [];
  }

  @override
  Stream<bool> watchIsLiked({required String postId, required String userId}) {
    return const Stream.empty();
  }

  @override
  Stream<List<Post>> watchUserPosts({
    required String userId,
    required int limit,
  }) {
    return const Stream.empty();
  }
}
