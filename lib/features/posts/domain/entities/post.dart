class Post {
  const Post({
    required this.id,
    required this.userId,
    required this.username,
    required this.userHandle,
    required this.userPhotoUrl,
    required this.text,
    required this.imageBase64,
    required this.imageUrl,
    required this.imagePath,
    required this.likesCount,
    required this.commentsCount,
    required this.sharesCount,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String username;
  final String userHandle;
  final String? userPhotoUrl;
  final String text;
  final String? imageBase64;
  final String? imageUrl;
  final String? imagePath;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
