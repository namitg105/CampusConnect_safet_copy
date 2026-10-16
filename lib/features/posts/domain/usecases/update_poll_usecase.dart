import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repos/post_repo.dart';
import 'post_params.dart';

class UpdatePollUseCase implements UseCase<void, UpdatePollParams> {
  final PostRepo repository;
  const UpdatePollUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(UpdatePollParams params) =>
      repository.updatePoll(params.postId, params.poll);
}
