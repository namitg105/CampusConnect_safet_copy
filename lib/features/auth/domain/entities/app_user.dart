class AppUser {
  final String uid;
  final String email;
  final String name;
  final bool isOnline;
  final bool isImageExists;
  final String imageURL;
  final String? phoneNumber;

  AppUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.isOnline,
    this.isImageExists = false,
    this.imageURL = '',
    this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'isOnline': isOnline,
      'isImageExists': isImageExists,
      'ImageURL': imageURL,
      'phoneNumber': phoneNumber,
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> jsonUser) {
    return AppUser(
      uid: jsonUser['uid'],
      email: jsonUser['email'],
      name: jsonUser['name'],
      isOnline: jsonUser['isOnline'] ?? false,
      isImageExists: jsonUser['isImageExists'] ?? false,
      imageURL: jsonUser['ImageURL'] ?? '',
      phoneNumber: jsonUser['phoneNumber'],
    );
  }

  factory AppUser.fromFriendJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      isOnline: json['isOnline'] ?? false,
      isImageExists: json['isImageExists'] ?? false,
      imageURL: json['ImageURL'] ?? '',
      phoneNumber: json['phoneNumber'],
    );
  }
}
