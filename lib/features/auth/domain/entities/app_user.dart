class AppUser {
  final String uid;
  final String email;
  final String name;
  final String collegeId; // Added for the Reddit-style segregation
  final bool isOnline;
  final bool isImageExists;
  final String imageURL;
  final String? phoneNumber;

  AppUser({
    required this.uid, 
    required this.email, 
    required this.name,
    required this.collegeId, // Require it in the constructor
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
      'collegeId': collegeId, // Save it to the database
      'isOnline': isOnline,
      'isImageExists': isImageExists,
      'ImageURL': imageURL,
      'phoneNumber': phoneNumber,
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> jsonUser) {
    return AppUser(
      uid: jsonUser['uid'] ?? '',
      email: jsonUser['email'] ?? '',
      name: jsonUser['name'] ?? '',
      collegeId: jsonUser['collegeId'] ?? '', // Read it from the database
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
      collegeId: json['collegeId'] ?? '',
      isOnline: json['isOnline'] ?? false,
      isImageExists: json['isImageExists'] ?? false,
      imageURL: json['ImageURL'] ?? '',
      phoneNumber: json['phoneNumber'],
    );
  }
}
