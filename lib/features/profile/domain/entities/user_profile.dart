class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String collegeId;
  final String department;
  final int year;
  final String imageUrl;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.collegeId,
    required this.department,
    required this.year,
    required this.imageUrl,
  });

  factory UserProfile.fromMap(
    Map<String, dynamic> map,
  ) {
    return UserProfile(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      collegeId: map['collegeId'] ?? '',
      department: map['department'] ?? '',
      year: map['year'] ?? 0,
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'collegeId': collegeId,
      'department': department,
      'year': year,
      'imageUrl': imageUrl,
    };
  }
}
