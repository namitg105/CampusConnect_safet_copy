class AppUser {
  final String uid;
  final String email;
  final String name;
  final String collegeId; // Added for the Reddit-style segregation

  AppUser({
    required this.uid, 
    required this.email, 
    required this.name,
    required this.collegeId, // Require it in the constructor
  });

  // Convert AppUser -> JSON (For saving to Firestore)
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'collegeId': collegeId, // Save it to the database
    };
  }

  // Convert JSON -> AppUser (For reading from Firestore)
  factory AppUser.fromJson(Map<String, dynamic> jsonUser) {
    return AppUser(
      uid: jsonUser['uid'] ?? '',
      email: jsonUser['email'] ?? '',
      name: jsonUser['name'] ?? '',
      collegeId: jsonUser['collegeId'] ?? '', // Read it from the database
    );
  }
}