import 'package:circle/core/theme/app_theme.dart';
import 'package:circle/features/feed/presentation/widgets/post_card.dart';
import 'package:circle/features/posts/domain/entities/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('PostCard renders Base64 image posts from memory', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: Scaffold(
          body: PostCard(post: _imagePost, actions: const SizedBox.shrink()),
        ),
      ),
    );

    expect(find.byType(Image), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

const _imagePost = Post(
  id: 'p1',
  userId: 'u1',
  username: 'Maya Chen',
  userHandle: '@maya',
  userPhotoUrl: null,
  text: 'Image post',
  imageBase64:
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+/p9sAAAAASUVORK5CYII=',
  imageUrl: null,
  imagePath: null,
  likesCount: 0,
  commentsCount: 0,
  sharesCount: 0,
  createdAt: null,
  updatedAt: null,
);
