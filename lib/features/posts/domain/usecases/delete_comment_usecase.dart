import '../repos/post_repo.dart';

class DeleteCommentUseCase {
  final PostRepo repository;

  DeleteCommentUseCase({required this.repository});

  Future<void> call(String postId, String commentId, String userId) async {
    await repository.deleteComment(postId, commentId, userId);
  }
}
