import '../repos/post_repo.dart';

class DownvotePostUseCase {
  final PostRepo repository;

  DownvotePostUseCase({required this.repository});

  Future<void> call(String postId, String userId) async {
    return repository.downvotePost(postId, userId);
  }
}
