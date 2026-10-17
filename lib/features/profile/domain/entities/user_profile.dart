/// A user's public profile (`users/{uid}`).
///
/// Fields are nullable on purpose: screens fall back to the logged-in
/// user's auth data when a profile field was never set.
class UserProfile {
  final String uid;
  final String? name;
  final String? email;
  final String? bio;
  final String? profileImage;
  final String? collegeId;

  const UserProfile({
    required this.uid,
    this.name,
    this.email,
    this.bio,
    this.profileImage,
    this.collegeId,
  });

  bool get hasImage => profileImage != null && profileImage!.isNotEmpty;
}

/// What to do with the profile picture when saving.
sealed class ProfileImageChange {
  const ProfileImageChange();
}

final class KeepImage extends ProfileImageChange {
  const KeepImage();
}

/// Back to the default avatar (the stored picture is deleted).
final class ResetImage extends ProfileImageChange {
  const ResetImage();
}

final class ReplaceImage extends ProfileImageChange {
  final String localPath;
  const ReplaceImage(this.localPath);
}
