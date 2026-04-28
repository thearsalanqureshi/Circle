import '../../../profile/domain/entities/user_profile.dart';
import '../entities/comment.dart';
import '../entities/post.dart';

abstract class PostRepository {
  Stream<List<Post>> watchFeedPosts({required int limit});

  Future<List<Post>> fetchFeedPostsPage({
    required int limit,
    DateTime? startAfterCreatedAt,
  });

  Stream<List<Post>> watchUserPosts({
    required String userId,
    required int limit,
  });

  Future<void> createPost({
    required String postId,
    required UserProfile author,
    required String text,
    required String? imageBase64,
  });

  Stream<bool> watchIsLiked({required String postId, required String userId});

  Future<void> toggleLike({required String postId, required String userId});

  Stream<List<Comment>> watchComments({
    required String postId,
    required int limit,
  });

  Future<void> addComment({
    required String postId,
    required UserProfile author,
    required String text,
  });
}
