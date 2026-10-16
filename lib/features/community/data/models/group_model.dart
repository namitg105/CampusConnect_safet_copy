import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/group.dart';

/// Firestore mapping for `groups/{groupId}`.
///
/// ```json
/// {
///   "name": "Coding Club", "collegeId": "nith.ac.in", "description": "...",
///   "category": "Education", "isPublic": true, "rules": ["Be kind"],
///   "memberCount": 12, "maxMembers": 50, "remainingSeats": 38,
///   "createdBy": "uid1", "imageUrl": "", "createdAt": <server timestamp>
/// }
/// ```
class GroupModel extends Group {
  const GroupModel({
    required super.id,
    required super.name,
    required super.collegeId,
    required super.description,
    required super.category,
    required super.isPublic,
    required super.rules,
    required super.memberCount,
    required super.maxMembers,
    required super.remainingSeats,
    required super.createdBy,
    required super.imageUrl,
    super.createdAt,
  });

  factory GroupModel.fromMap(String id, Map<String, dynamic> map) {
    return GroupModel(
      id: id,
      name: map['name'] ?? '',
      collegeId: map['collegeId'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'Education',
      isPublic: map['isPublic'] ?? true,
      rules: List<String>.from(map['rules'] ?? []),
      memberCount: ((map['memberCount'] ?? 0) as num).toInt(),
      maxMembers: ((map['maxMembers'] ?? 50) as num).toInt(),
      remainingSeats: ((map['remainingSeats'] ?? 50) as num).toInt(),
      createdBy: map['createdBy'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  static Map<String, dynamic> toMap(Group group) {
    return {
      'name': group.name,
      'collegeId': group.collegeId,
      'description': group.description,
      'category': group.category,
      'isPublic': group.isPublic,
      'rules': group.rules,
      'memberCount': group.memberCount,
      'maxMembers': group.maxMembers,
      'remainingSeats': group.remainingSeats,
      'createdBy': group.createdBy,
      'imageUrl': group.imageUrl,
      'createdAt': group.createdAt == null
          ? null
          : Timestamp.fromDate(group.createdAt!),
    };
  }
}
