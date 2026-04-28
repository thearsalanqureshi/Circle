import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.displayName,
    required super.email,
    required super.photoUrl,
    required super.bio,
    required super.postsCount,
    required super.followersCount,
    required super.followingCount,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserProfileModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? <String, dynamic>{};
    return UserProfileModel(
      id: snapshot.id,
      displayName: data['displayName'] as String? ?? '',
      email: data['email'] as String?,
      photoUrl: data['photoUrl'] as String?,
      bio: data['bio'] as String? ?? '',
      postsCount: data['postsCount'] as int? ?? 0,
      followersCount: data['followersCount'] as int? ?? 0,
      followingCount: data['followingCount'] as int? ?? 0,
      createdAt: _dateTimeFrom(data['createdAt']),
      updatedAt: _dateTimeFrom(data['updatedAt']),
    );
  }

  static Map<String, dynamic> createMap({
    required String id,
    required String displayName,
    required String? email,
    required String? photoUrl,
  }) {
    return {
      'id': id,
      'displayName': displayName,
      'displayNameLowercase': displayName.trim().toLowerCase(),
      'email': email,
      'photoUrl': photoUrl,
      'bio': '',
      'postsCount': 0,
      'followersCount': 0,
      'followingCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static DateTime? _dateTimeFrom(Object? value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    return null;
  }
}
