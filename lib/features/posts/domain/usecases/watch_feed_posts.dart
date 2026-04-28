import '../entities/post.dart';
import '../repositories/post_repository.dart';

class WatchFeedPosts {
  const WatchFeedPosts(this._repository);

  final PostRepository _repository;

  Stream<List<Post>> call({required int limit}) {
    return _repository.watchFeedPosts(limit: limit);
  }
}
