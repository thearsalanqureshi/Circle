import 'package:circle/core/constants/firebase_paths.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FirebasePaths', () {
    test('builds required user and post collection paths', () {
      expect(FirebasePaths.user('u1'), 'users/u1');
      expect(FirebasePaths.post('p1'), 'posts/p1');
    });

    test('builds required post subcollection paths', () {
      expect(FirebasePaths.likes, 'likes');
      expect(FirebasePaths.comments, 'comments');
      expect(FirebasePaths.postLike('p1', 'u1'), 'posts/p1/likes/u1');
      expect(FirebasePaths.postComment('p1', 'c1'), 'posts/p1/comments/c1');
    });
  });
}
