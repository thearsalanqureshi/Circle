import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/comment.dart';

class CommentModel extends Comment {
  const CommentModel({
    required super.id,
    required super.postId,
    required super.userId,
    required super.username,
    required super.userPhotoUrl,
    required super.text,
    required super.createdAt,
  });

  factory CommentModel.fromSnapshot({
    required String postId,
    required DocumentSnapshot<Map<String, dynamic>> snapshot,
  }) {
    final data = snapshot.data() ?? <String, dynamic>{};
    return CommentModel(
      id: snapshot.id,
      postId: postId,
      userId: data['userId'] as String? ?? '',
      username: data['username'] as String? ?? '',
      userPhotoUrl: data['userPhotoUrl'] as String?,
      text: data['text'] as String? ?? '',
      createdAt: _dateTimeFrom(data['createdAt']),
    );
  }

  static Map<String, dynamic> createMap({
    required String id,
    required String postId,
    required String userId,
    required String username,
    required String? userPhotoUrl,
    required String text,
  }) {
    return {
      'id': id,
      'postId': postId,
      'userId': userId,
      'username': username,
      'userPhotoUrl': userPhotoUrl,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  static DateTime? _dateTimeFrom(Object? value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    return null;
  }
}
