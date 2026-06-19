class Group {
  final String id;
  final String name;
  final String collegeId;
  final String description;
  final int memberCount;

  Group({
    required this.id,
    required this.name,
    required this.collegeId,
    required this.description,
    required this.memberCount,
  });

  factory Group.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return Group(
      id: id,
      name: map['name'] ?? '',
      collegeId: map['collegeId'] ?? '',
      description: map['description'] ?? '',
      memberCount: map['memberCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'collegeId': collegeId,
      'description': description,
      'memberCount': memberCount,
    };
  }
}
