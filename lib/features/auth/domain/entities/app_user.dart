import 'package:equatable/equatable.dart';

/// The logged-in campus user as the rest of the app sees it.
/// Pure Dart: JSON / Firestore mapping lives in `AppUserModel` (data layer).
class AppUser extends Equatable {
  final String uid;
  final String email;
  final String name;
  final String collegeId; // e.g. "nith.ac.in" — used for Reddit-style segregation
  final bool isOnline;
  final bool isImageExists;
  final String imageURL;
  final String? phoneNumber;

  const AppUser({
    required this.uid,
    required this.email,
    required this.name,
    this.collegeId = '',
    this.isOnline = false,
    this.isImageExists = false,
    this.imageURL = '',
    this.phoneNumber,
  });

  AppUser copyWith({String? name}) {
    return AppUser(
      uid: uid,
      email: email,
      name: name ?? this.name,
      collegeId: collegeId,
      isOnline: isOnline,
      isImageExists: isImageExists,
      imageURL: imageURL,
      phoneNumber: phoneNumber,
    );
  }

  @override
  List<Object?> get props => [
        uid,
        email,
        name,
        collegeId,
        isOnline,
        isImageExists,
        imageURL,
        phoneNumber,
      ];
}
