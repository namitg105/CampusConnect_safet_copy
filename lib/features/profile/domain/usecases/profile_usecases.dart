import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user_profile.dart';
import '../repos/profile_repo.dart';

/// Params: the user's uid.
class GetProfile implements UseCase<UserProfile?, String> {
  final ProfileRepo repo;
  const GetProfile(this.repo);

  @override
  Future<Either<Failure, UserProfile?>> call(String uid) =>
      repo.getProfile(uid);
}

class UpdateProfileParams {
  final String uid;
  final String name;
  final String bio;
  final ProfileImageChange image;
  final String? currentImageUrl;
  const UpdateProfileParams({
    required this.uid,
    required this.name,
    required this.bio,
    required this.image,
    this.currentImageUrl,
  });
}

/// Returns the saved name.
class UpdateProfile implements UseCase<String, UpdateProfileParams> {
  final ProfileRepo repo;
  const UpdateProfile(this.repo);

  @override
  Future<Either<Failure, String>> call(UpdateProfileParams p) =>
      repo.updateProfile(
        uid: p.uid,
        name: p.name,
        bio: p.bio,
        image: p.image,
        currentImageUrl: p.currentImageUrl,
      );
}
