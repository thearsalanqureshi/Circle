import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/post.dart';

class PostModel extends Post {
  const PostModel({
    required super.id,
    required super.userId,
    required super.username,
    required super.userHandle,
    required super.userPhotoUrl,
    required super.text,
    required super.imageBase64,
    required super.imageUrl,
    required super.imagePath,
    required super.likesCount,
    required super.commentsCount,
    required super.sharesCount,
    required super.createdAt,
    required super.updatedAt,
  });

  factory PostModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? <String, dynamic>{};
    return PostModel(
      id: snapshot.id,
      userId: data['userId'] as String? ?? '',
      username: data['username'] as String? ?? '',
      userHandle: data['userHandle'] as String? ?? '',
      userPhotoUrl: data['userPhotoUrl'] as String?,
      text: data['text'] as String? ?? '',
      imageBase64: data['imageBase64'] as String?,
      imageUrl: data['imageUrl'] as String?,
      imagePath: data['imagePath'] as String?,
      likesCount: data['likesCount'] as int? ?? 0,
      commentsCount: data['commentsCount'] as int? ?? 0,
      sharesCount: data['sharesCount'] as int? ?? 0,
      createdAt: _dateTimeFrom(data['createdAt']),
      updatedAt: _dateTimeFrom(data['updatedAt']),
    );
  }

  factory PostModel.fromCacheMap(Map<String, dynamic> data) {
    return PostModel(
      id: data['id'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      username: data['username'] as String? ?? '',
      userHandle: data['userHandle'] as String? ?? '',
      userPhotoUrl: data['userPhotoUrl'] as String?,
      text: data['text'] as String? ?? '',
      imageBase64: data['imageBase64'] as String?,
      imageUrl: data['imageUrl'] as String?,
      imagePath: data['imagePath'] as String?,
      likesCount: data['likesCount'] as int? ?? 0,
      commentsCount: data['commentsCount'] as int? ?? 0,
      sharesCount: data['sharesCount'] as int? ?? 0,
      createdAt: _dateTimeFrom(data['createdAt']),
      updatedAt: _dateTimeFrom(data['updatedAt']),
    );
  }

  static Map<String, dynamic> toCacheMap(Post post) {
    return {
      'id': post.id,
      'userId': post.userId,
      'username': post.username,
      'userHandle': post.userHandle,
      'userPhotoUrl': post.userPhotoUrl,
      'text': post.text,
      'imageBase64': post.imageBase64,
      'imageUrl': post.imageUrl,
      'imagePath': post.imagePath,
      'likesCount': post.likesCount,
      'commentsCount': post.commentsCount,
      'sharesCount': post.sharesCount,
      'createdAt': post.createdAt?.toIso8601String(),
      'updatedAt': post.updatedAt?.toIso8601String(),
    };
  }

  static Map<String, dynamic> createMap({
    required String id,
    required String userId,
    required String username,
    required String userHandle,
    required String? userPhotoUrl,
    required String text,
    required String? imageBase64,
  }) {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'userHandle': userHandle,
      'userPhotoUrl': userPhotoUrl,
      'text': text,
      'imageBase64': imageBase64,
      'likesCount': 0,
      'commentsCount': 0,
      'sharesCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static DateTime? _dateTimeFrom(Object? value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
