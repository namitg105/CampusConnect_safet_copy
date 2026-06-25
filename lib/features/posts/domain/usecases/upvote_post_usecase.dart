import '../repos/post_repo.dart';

/// Day 6: Handle user upvote action on a post
class UpvotePostUseCase {
  final PostRepo repository;

  UpvotePostUseCase({required this.repository});

  Future<void> call(String postId, String userId) async {
    return repository.upvotePost(postId, userId);
  }
}
