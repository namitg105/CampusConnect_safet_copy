import '../repos/post_repo.dart';

class ToggleCommentLikeUseCase {
  final PostRepo repository;

  ToggleCommentLikeUseCase({required this.repository});

  Future<void> call(String postId, String commentId, String userId) async {
    await repository.toggleCommentLike(postId, commentId, userId);
  }
}
