import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repos/post_repo.dart';
import 'post_params.dart';

class GetUserLikedCommentsUseCase implements UseCase<Map<String, bool>, LikedCommentsParams> {
  final PostRepo repository;
  const GetUserLikedCommentsUseCase({required this.repository});

  @override
  Future<Either<Failure, Map<String, bool>>> call(LikedCommentsParams params) =>
      repository.getUserLikedComments(params.postId, params.userId, params.commentIds);
}
