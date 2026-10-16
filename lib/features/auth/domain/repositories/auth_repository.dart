import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/app_user.dart';

/// Contract for every auth operation. The data layer implements it;
/// the domain/presentation layers only ever see this interface.
abstract interface class AuthRepository {
  Future<Either<Failure, AppUser>> loginWithEmailPassword({
    required String email,
    required String password,
  });

  Future<Either<Failure, AppUser>> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  });

  /// `Right(null)` means the user closed the Google picker.
  Future<Either<Failure, AppUser?>> loginWithGoogle();

  /// `Right(null)` means nobody is logged in.
  Future<Either<Failure, AppUser?>> getCurrentUser();

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, void>> sendPasswordResetEmail(String email);
}
