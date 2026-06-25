import '../entities/post_entity.dart';
import '../repos/post_repo.dart';

/// Day 3: Filter posts by tag within the user's college
class GetFeedByTagUseCase {
  final PostRepo repository;

  GetFeedByTagUseCase({required this.repository});

  Future<List<PostEntity>> call(String collegeId, String tag) async {
    return repository.getCollegeFeedByTag(collegeId, tag);
  }
}
