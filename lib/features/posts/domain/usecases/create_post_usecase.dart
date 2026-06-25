import '../entities/post_entity.dart';
import '../repos/post_repo.dart';

class CreatePostUseCase {
  final PostRepo repository;

  CreatePostUseCase({required this.repository});

  Future<void> call(PostEntity post) async {
    await repository.createPost(post);
  }
}
