import '../entities/post.dart';
import '../repositories/post_repository.dart';

class WatchUserPosts {
  const WatchUserPosts(this._repository);

  final PostRepository _repository;

  Stream<List<Post>> call({required String userId, required int limit}) {
    return _repository.watchUserPosts(userId: userId, limit: limit);
  }
}
