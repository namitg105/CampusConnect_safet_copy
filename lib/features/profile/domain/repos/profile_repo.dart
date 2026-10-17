import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/user_profile.dart';

abstract interface class ProfileRepo {
  /// `Right(null)` when the user has no profile document.
  Future<Either<Failure, UserProfile?>> getProfile(String uid);

  /// Saves name + bio, uploads/removes the picture, and keeps the Firebase
  /// Auth display name in sync. Returns the saved name.
  Future<Either<Failure, String>> updateProfile({
    required String uid,
    required String name,
    required String bio,
    required ProfileImageChange image,
    required String? currentImageUrl,
  });
}
