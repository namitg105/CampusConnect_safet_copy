import 'package:cloud_firestore/cloud_firestore.dart';

class VoteEntity {
  final String userId;
  final int voteValue; // 1 for upvote, -1 for downvote, 0 for remove

  VoteEntity({
    required this.userId,
    required this.voteValue,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'voteValue': voteValue,
      'votedAt': Timestamp.now(),
    };
  }

  factory VoteEntity.fromJson(Map<String, dynamic> json) {
    return VoteEntity(
      userId: json['userId'] ?? '',
      voteValue: (json['voteValue'] ?? 0) as int,
    );
  }
}
