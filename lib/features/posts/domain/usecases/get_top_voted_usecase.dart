import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/post_entity.dart';
import '../repos/post_repo.dart';

/// Params: the college id. Most upvoted first.
class GetTopVotedPostsUseCase implements UseCase<List<PostEntity>, String> {
  final PostRepo repository;
  const GetTopVotedPostsUseCase({required this.repository});

  @override
  Future<Either<Failure, List<PostEntity>>> call(String params) =>
      repository.getTopVotedPosts(params);
}
