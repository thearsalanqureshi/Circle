import '../repositories/post_repository.dart';

class TogglePostLike {
  const TogglePostLike(this._repository);

  final PostRepository _repository;

  Future<void> call({required String postId, required String userId}) {
    return _repository.toggleLike(postId: postId, userId: userId);
  }
}
