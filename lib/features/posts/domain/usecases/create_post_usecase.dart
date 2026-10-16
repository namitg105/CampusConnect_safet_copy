import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/post_entity.dart';
import '../repos/post_repo.dart';

class CreatePostUseCase implements UseCase<void, PostEntity> {
  final PostRepo repository;
  const CreatePostUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(PostEntity params) =>
      repository.createPost(params);
}
