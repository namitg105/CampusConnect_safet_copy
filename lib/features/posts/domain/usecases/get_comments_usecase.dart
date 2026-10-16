import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/comment_entity.dart';
import '../repos/post_repo.dart';

/// Params: the post id. Oldest first.
class GetCommentsUseCase implements UseCase<List<CommentEntity>, String> {
  final PostRepo repository;
  const GetCommentsUseCase({required this.repository});

  @override
  Future<Either<Failure, List<CommentEntity>>> call(String params) =>
      repository.getComments(params);
}
