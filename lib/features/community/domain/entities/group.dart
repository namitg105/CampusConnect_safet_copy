import 'package:cloud_firestore/cloud_firestore.dart';

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
  final Timestamp? createdAt;

  Group({
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

  factory Group.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return Group(
      id: id,
      name: map['name'] ?? '',
      collegeId: map['collegeId'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'Education',
      isPublic: map['isPublic'] ?? true,
      rules: List<String>.from(map['rules'] ?? []),
      memberCount: map['memberCount'] ?? 0,
      maxMembers: map['maxMembers'] ?? 50,
      remainingSeats: map['remainingSeats'] ?? 50,
      createdBy: map['createdBy'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      createdAt: map['createdAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'collegeId': collegeId,
      'description': description,
      'category': category,
      'isPublic': isPublic,
      'rules': rules,
      'memberCount': memberCount,
      'maxMembers': maxMembers,
      'remainingSeats': remainingSeats,
      'createdBy': createdBy,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
    };
  }

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
    Timestamp? createdAt,
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
