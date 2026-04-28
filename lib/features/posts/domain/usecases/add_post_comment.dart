import '../../../profile/domain/entities/user_profile.dart';
import '../repositories/post_repository.dart';

class AddPostComment {
  const AddPostComment(this._repository);

  final PostRepository _repository;

  Future<void> call({
    required String postId,
    required UserProfile author,
    required String text,
  }) {
    return _repository.addComment(postId: postId, author: author, text: text);
  }
}
