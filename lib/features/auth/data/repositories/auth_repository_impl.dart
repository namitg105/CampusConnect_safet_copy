import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/guard.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  const AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, AppUser>> loginWithEmailPassword({
    required String email,
    required String password,
  }) {
    return guardFuture(() => remoteDataSource.loginWithEmailPassword(
          email: email,
          password: password,
        ));
  }

  @override
  Future<Either<Failure, AppUser>> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  }) {
    return guardFuture(() => remoteDataSource.signUpWithEmailPassword(
          name: name,
          email: email,
          password: password,
        ));
  }

  @override
  Future<Either<Failure, AppUser?>> loginWithGoogle() {
    return guardFuture(remoteDataSource.loginWithGoogle);
  }

  @override
  Future<Either<Failure, AppUser?>> getCurrentUser() {
    return guardFuture(remoteDataSource.getCurrentUser);
  }

  @override
  Future<Either<Failure, void>> logout() {
    return guardFuture(remoteDataSource.logout);
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) {
    return guardFuture(() => remoteDataSource.sendPasswordResetEmail(email));
  }
}
