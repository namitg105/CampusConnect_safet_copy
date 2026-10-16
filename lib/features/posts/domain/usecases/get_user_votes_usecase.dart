import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repos/post_repo.dart';
import 'post_params.dart';

class GetUserVotesUseCase implements UseCase<Map<String, int>, UserVotesParams> {
  final PostRepo repository;
  const GetUserVotesUseCase({required this.repository});

  @override
  Future<Either<Failure, Map<String, int>>> call(UserVotesParams params) =>
      repository.getUserVotesForPosts(params.userId, params.postIds);
}
