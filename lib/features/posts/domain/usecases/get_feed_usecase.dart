import '../entities/post_entity.dart';
import '../repos/post_repo.dart';

class GetFeedUseCase {
  final PostRepo repository;

  GetFeedUseCase({required this.repository});

  Future<List<PostEntity>> call(String collegeId) async {
    return repository.getCollegeFeed(collegeId);
  }
}
