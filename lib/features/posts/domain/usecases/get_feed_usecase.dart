import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/post_entity.dart';
import '../repos/post_repo.dart';

/// Params: the college id. Newest first.
class GetFeedUseCase implements UseCase<List<PostEntity>, String> {
  final PostRepo repository;
  const GetFeedUseCase({required this.repository});

  @override
  Future<Either<Failure, List<PostEntity>>> call(String params) =>
      repository.getCollegeFeed(params);
}
