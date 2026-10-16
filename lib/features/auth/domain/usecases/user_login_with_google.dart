import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

/// Returns `Right(null)` when the user cancels the Google account picker.
class UserLoginWithGoogle implements UseCase<AppUser?, NoParams> {
  final AuthRepository authRepository;
  const UserLoginWithGoogle(this.authRepository);

  @override
  Future<Either<Failure, AppUser?>> call(NoParams params) {
    return authRepository.loginWithGoogle();
  }
}
