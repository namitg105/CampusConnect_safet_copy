import '../repos/post_repo.dart';

class GetUserLikedCommentsUseCase {
  final PostRepo repository;

  GetUserLikedCommentsUseCase({required this.repository});

  Future<Map<String, bool>> call(
      String postId, String userId, List<String> commentIds) async {
    return await repository.getUserLikedComments(postId, userId, commentIds);
  }
}
