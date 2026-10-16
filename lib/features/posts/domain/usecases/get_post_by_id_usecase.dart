import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/post_entity.dart';
import '../repos/post_repo.dart';

/// Params: the post id. `Right(null)` when the post no longer exists.
class GetPostByIdUseCase implements UseCase<PostEntity?, String> {
  final PostRepo repository;
  const GetPostByIdUseCase({required this.repository});

  @override
  Future<Either<Failure, PostEntity?>> call(String params) =>
      repository.getPostById(params);
}
