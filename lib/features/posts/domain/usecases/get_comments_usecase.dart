import '../entities/comment_entity.dart';
import '../repos/post_repo.dart';

class GetCommentsUseCase {
  final PostRepo repository;

  GetCommentsUseCase({required this.repository});

  Future<List<CommentEntity>> call(String postId) async {
    return repository.getComments(postId);
  }
}
