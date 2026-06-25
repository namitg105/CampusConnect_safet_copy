import '../entities/post_entity.dart';
import '../repos/post_repo.dart';

/// Day 3: Fetch top voted posts in the user's college (sorted by upvotes)
class GetTopVotedPostsUseCase {
  final PostRepo repository;

  GetTopVotedPostsUseCase({required this.repository});

  Future<List<PostEntity>> call(String collegeId) async {
    return repository.getTopVotedPosts(collegeId);
  }
}
