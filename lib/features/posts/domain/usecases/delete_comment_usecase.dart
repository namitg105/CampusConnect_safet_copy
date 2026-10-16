import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repos/post_repo.dart';
import 'post_params.dart';

class DeleteCommentUseCase implements UseCase<void, CommentUserParams> {
  final PostRepo repository;
  const DeleteCommentUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(CommentUserParams params) =>
      repository.deleteComment(params.postId, params.commentId, params.userId);
}
