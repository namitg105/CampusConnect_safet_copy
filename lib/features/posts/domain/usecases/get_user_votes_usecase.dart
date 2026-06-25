import '../repos/post_repo.dart';

class GetUserVotesUseCase {
  final PostRepo repository;

  GetUserVotesUseCase({required this.repository});

  Future<Map<String, int>> call(String userId, List<String> postIds) async {
    return await repository.getUserVotesForPosts(userId, postIds);
  }
}
