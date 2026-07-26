import '../entities/user_profile.dart';

abstract class ProfileRepo {
  Future<UserProfile> getProfile(
    String uid,
  );
}
