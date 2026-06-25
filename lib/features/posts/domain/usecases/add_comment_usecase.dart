import '../entities/comment_entity.dart';
import '../repos/post_repo.dart';

class AddCommentUseCase {
  final PostRepo repository;

  AddCommentUseCase({required this.repository});

  Future<void> call(CommentEntity comment) async {
    await repository.addComment(comment);
  }
}
