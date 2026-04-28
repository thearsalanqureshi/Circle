import '../entities/comment.dart';
import '../repositories/post_repository.dart';

class WatchPostComments {
  const WatchPostComments(this._repository);

  final PostRepository _repository;

  Stream<List<Comment>> call({required String postId, required int limit}) {
    return _repository.watchComments(postId: postId, limit: limit);
  }
}
