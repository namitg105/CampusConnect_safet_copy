import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomEntity {
  final String id;
  final String name;
  final String collegeId;
  final List<String> participants;
  final String lastMessage;
  final DateTime lastUpdated;
  final DateTime createdAt;

  ChatRoomEntity({
    required this.id,
    required this.name,
    required this.collegeId,
    required this.participants,
    required this.lastMessage,
    required this.lastUpdated,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'collegeId': collegeId,
      'participants': participants,
      'lastMessage': lastMessage,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ChatRoomEntity.fromJson(Map<String, dynamic> json, String id) {
    final lastUpdatedValue = json['lastUpdated'];
    final createdAtValue = json['createdAt'];

    return ChatRoomEntity(
      id: id,
      name: json['name'] ?? '',
      collegeId: json['collegeId'] ?? '',
      participants: List<String>.from(json['participants'] ?? <String>[]),
      lastMessage: json['lastMessage'] ?? '',
      lastUpdated: lastUpdatedValue is Timestamp
          ? lastUpdatedValue.toDate()
          : DateTime.tryParse(lastUpdatedValue?.toString() ?? '') ?? DateTime.now(),
      createdAt: createdAtValue is Timestamp
          ? createdAtValue.toDate()
          : DateTime.tryParse(createdAtValue?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
