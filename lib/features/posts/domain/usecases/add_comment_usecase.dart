import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/comment_entity.dart';
import '../repos/post_repo.dart';

class AddCommentUseCase implements UseCase<void, CommentEntity> {
  final PostRepo repository;
  const AddCommentUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(CommentEntity params) =>
      repository.addComment(params);
}
