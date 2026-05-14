import 'package:circle/features/posts/data/models/post_model.dart';
import 'package:circle/features/posts/domain/entities/post.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PostModel cache serialization', () {
    test('round-trips Base64 posts for Hive feed cache', () {
      final createdAt = DateTime.utc(2026, 4, 29, 9, 30);
      final updatedAt = DateTime.utc(2026, 4, 29, 9, 45);
      final post = Post(
        id: 'p1',
        userId: 'u1',
        username: 'Maya Chen',
        userHandle: '@maya',
        userPhotoUrl: null,
        text: 'Hello Circle',
        imageBase64: 'aW1hZ2U=',
        imageUrl: null,
        imagePath: null,
        likesCount: 7,
        commentsCount: 2,
        sharesCount: 1,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      final cached = PostModel.toCacheMap(post);
      final restored = PostModel.fromCacheMap(cached);

      expect(restored.id, post.id);
      expect(restored.userId, post.userId);
      expect(restored.text, post.text);
      expect(restored.imageBase64, post.imageBase64);
      expect(restored.likesCount, post.likesCount);
      expect(restored.commentsCount, post.commentsCount);
      expect(restored.createdAt, createdAt);
      expect(restored.updatedAt, updatedAt);
    });
  });
}
