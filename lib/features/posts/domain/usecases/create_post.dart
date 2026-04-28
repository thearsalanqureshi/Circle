import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../../../core/constants/app_limits.dart';
import '../../../../core/errors/image_too_large_exception.dart';
import '../../../profile/domain/entities/user_profile.dart';
import '../entities/post.dart';
import '../entities/selected_post_image.dart';
import '../repositories/post_repository.dart';

class CreatePost {
  CreatePost({required PostRepository postRepository})
    : _postRepository = postRepository;

  final PostRepository _postRepository;
  final Random _random = Random.secure();

  Future<Post> call({
    required UserProfile author,
    required String text,
    SelectedPostImage? image,
  }) async {
    final trimmedText = text.trim();
    final imageBase64 = _base64For(image);
    final postId = _newPostId();
    final createdAt = DateTime.now();

    await _postRepository.createPost(
      postId: postId,
      author: author,
      text: trimmedText,
      imageBase64: imageBase64,
    );

    return Post(
      id: postId,
      userId: author.id,
      username: author.displayName,
      userHandle: _handleFor(author),
      userPhotoUrl: author.photoUrl,
      text: trimmedText,
      imageBase64: imageBase64,
      imageUrl: null,
      imagePath: null,
      likesCount: 0,
      commentsCount: 0,
      sharesCount: 0,
      createdAt: createdAt,
      updatedAt: createdAt,
    );
  }

  String _newPostId() {
    final timestamp = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    final random = List.generate(
      8,
      (_) => _random.nextInt(36).toRadixString(36),
    ).join();
    return '$timestamp$random';
  }

  String? _base64For(SelectedPostImage? image) {
    if (image == null) {
      return null;
    }

    final size = image.sizeInBytes;
    debugPrint('CreatePost: compressed image size=$size bytes');
    if (size > AppLimits.maxPostImageBytes) {
      debugPrint('CreatePost: rejecting oversized image size=$size bytes');
      throw const ImageTooLargeException();
    }

    final base64 = base64Encode(image.bytes);
    final estimatedDocumentBytes = utf8.encode(base64).length;
    if (estimatedDocumentBytes > AppLimits.documentRiskBytes) {
      debugPrint(
        'CreatePost: document size risk=$estimatedDocumentBytes bytes',
      );
    }
    return base64;
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
}
