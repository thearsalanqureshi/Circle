import '../../../auth/domain/entities/app_user.dart';

class UserProfile {
  const UserProfile({
    required this.id,
    required this.displayName,
    required this.email,
    required this.photoUrl,
    required this.bio,
    required this.interestTags,
    required this.postsCount,
    required this.followersCount,
    required this.followingCount,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String displayName;
  final String? email;
  final String? photoUrl;
  final String bio;
  final List<String> interestTags;
  final int postsCount;
  final int followersCount;
  final int followingCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory UserProfile.fromAppUser(AppUser user) {
    return UserProfile(
      id: user.id,
      displayName: user.displayName?.trim().isNotEmpty == true
          ? user.displayName!.trim()
          : user.email?.split('@').first ?? user.id,
      email: user.email,
      photoUrl: null,
      bio: '',
      interestTags: const [],
      postsCount: 0,
      followersCount: 0,
      followingCount: 0,
      createdAt: null,
      updatedAt: null,
    );
  }
}
