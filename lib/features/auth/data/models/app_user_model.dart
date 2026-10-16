import '../../domain/entities/app_user.dart';

/// Firestore representation of [AppUser] (`users/{uid}` document).
///
/// Document shape stored in Firestore:
/// ```json
/// {
///   "uid": "abc123", "name": "Namit", "email": "namit@nith.ac.in",
///   "collegeId": "nith.ac.in", "isOnline": true, "isImageExists": false,
///   "ImageURL": "", "profileImage": "", "phoneNumber": null,
///   "createdAt": <server timestamp>
/// }
/// ```
class AppUserModel extends AppUser {
  const AppUserModel({
    required super.uid,
    required super.email,
    required super.name,
    super.collegeId,
    super.isOnline,
    super.isImageExists,
    super.imageURL,
    super.phoneNumber,
  });

  factory AppUserModel.fromJson(Map<String, dynamic> json) {
    return AppUserModel(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      collegeId: json['collegeId'] ?? '',
      isOnline: json['isOnline'] ?? false,
      isImageExists: json['isImageExists'] ?? false,
      imageURL: json['ImageURL'] ?? '',
      phoneNumber: json['phoneNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'collegeId': collegeId,
      'isOnline': isOnline,
      'isImageExists': isImageExists,
      'ImageURL': imageURL,
      'phoneNumber': phoneNumber,
    };
  }
}
