import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

/// Returns `Right(null)` when no session exists on this device.
class GetCurrentUser implements UseCase<AppUser?, NoParams> {
  final AuthRepository authRepository;
  const GetCurrentUser(this.authRepository);

  @override
  Future<Either<Failure, AppUser?>> call(NoParams params) {
    return authRepository.getCurrentUser();
  }
}
