import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repos/post_repo.dart';
import 'post_params.dart';

class ToggleCommentLikeUseCase implements UseCase<void, CommentUserParams> {
  final PostRepo repository;
  const ToggleCommentLikeUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(CommentUserParams params) =>
      repository.toggleCommentLike(params.postId, params.commentId, params.userId);
}
