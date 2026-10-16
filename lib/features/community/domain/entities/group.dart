/// A campus community. Pure Dart: Firestore mapping lives in `GroupModel`.
class Group {
  final String id;
  final String name;
  final String collegeId;
  final String description;
  final String category;
  final bool isPublic;
  final List<String> rules;
  final int memberCount;
  final int maxMembers;
  final int remainingSeats;
  final String createdBy;
  final String imageUrl;
  final DateTime? createdAt;

  const Group({
    required this.id,
    required this.name,
    required this.collegeId,
    required this.description,
    required this.category,
    required this.isPublic,
    required this.rules,
    required this.memberCount,
    required this.maxMembers,
    required this.remainingSeats,
    required this.createdBy,
    required this.imageUrl,
    this.createdAt,
  });

  Group copyWith({
    String? id,
    String? name,
    String? collegeId,
    String? description,
    String? category,
    bool? isPublic,
    List<String>? rules,
    int? memberCount,
    int? maxMembers,
    int? remainingSeats,
    String? createdBy,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      collegeId: collegeId ?? this.collegeId,
      description: description ?? this.description,
      category: category ?? this.category,
      isPublic: isPublic ?? this.isPublic,
      rules: rules ?? this.rules,
      memberCount: memberCount ?? this.memberCount,
      maxMembers: maxMembers ?? this.maxMembers,
      remainingSeats: remainingSeats ?? this.remainingSeats,
      createdBy: createdBy ?? this.createdBy,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
