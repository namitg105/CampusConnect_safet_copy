import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repos/post_repo.dart';
import 'post_params.dart';

class DownvotePostUseCase implements UseCase<void, PostUserParams> {
  final PostRepo repository;
  const DownvotePostUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(PostUserParams params) =>
      repository.downvotePost(params.postId, params.userId);
}
