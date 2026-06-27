import '../repos/post_repo.dart';

class DeletePostUseCase {
  final PostRepo repository;

  DeletePostUseCase({required this.repository});

  Future<void> call(String postId) async {
    await repository.deletePost(postId);
  }
}
