import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repos/post_repo.dart';

/// Params: the post id.
class DeletePostUseCase implements UseCase<void, String> {
  final PostRepo repository;
  const DeletePostUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(String params) =>
      repository.deletePost(params);
}
