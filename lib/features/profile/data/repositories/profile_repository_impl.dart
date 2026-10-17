import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/guard.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repos/profile_repo.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepo {
  final ProfileRemoteDataSource remote;
  const ProfileRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, UserProfile?>> getProfile(String uid) =>
      guardFuture(() => remote.getProfile(uid));

  @override
  Future<Either<Failure, String>> updateProfile({
    required String uid,
    required String name,
    required String bio,
    required ProfileImageChange image,
    required String? currentImageUrl,
  }) =>
      guardFuture(() => remote.updateProfile(
            uid: uid,
            name: name,
            bio: bio,
            image: image,
            currentImageUrl: currentImageUrl,
          ));
}
