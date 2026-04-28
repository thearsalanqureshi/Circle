class FirebasePaths {
  const FirebasePaths._();

  static const users = 'users';
  static const posts = 'posts';
  static const likes = 'likes';
  static const comments = 'comments';

  static String user(String userId) => '$users/$userId';

  static String post(String postId) => '$posts/$postId';

  static String postLike(String postId, String userId) {
    return '$posts/$postId/$likes/$userId';
  }

  static String postComment(String postId, String commentId) {
    return '$posts/$postId/$comments/$commentId';
  }
}
