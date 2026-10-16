import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class SendPasswordResetEmail implements UseCase<void, String> {
  final AuthRepository authRepository;
  const SendPasswordResetEmail(this.authRepository);

  @override
  Future<Either<Failure, void>> call(String email) {
    return authRepository.sendPasswordResetEmail(email);
  }
}
