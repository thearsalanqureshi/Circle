class Comment {
  const Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.username,
    required this.userPhotoUrl,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final String postId;
  final String userId;
  final String username;
  final String? userPhotoUrl;
  final String text;
  final DateTime? createdAt;
}
