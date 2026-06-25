import 'package:cloud_firestore/cloud_firestore.dart';

class PostEntity {
  final String id;
  final String title;
  final String body;
  final String authorId;
  final String authorName;
  final String collegeId;
  final int upvotes;
  final int commentCount;
  final String tag;
  final DateTime createdAt;
  final String? imageUrl;

  PostEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.authorId,
    required this.authorName,
    required this.collegeId,
    required this.upvotes,
    required this.commentCount,
    required this.tag,
    required this.createdAt,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'authorId': authorId,
      'authorName': authorName,
      'collegeId': collegeId,
      'upvotes': upvotes,
      'commentCount': commentCount,
      'tag': tag,
      'createdAt': Timestamp.fromDate(createdAt),
      'imageUrl': imageUrl,
    };
  }

  PostEntity copyWith({int? upvotes, int? commentCount, String? imageUrl}) {
    return PostEntity(
      id: id,
      title: title,
      body: body,
      authorId: authorId,
      authorName: authorName,
      collegeId: collegeId,
      upvotes: upvotes ?? this.upvotes,
      commentCount: commentCount ?? this.commentCount,
      tag: tag,
      createdAt: createdAt,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  factory PostEntity.fromJson(Map<String, dynamic> json, String id) {
    final createdAtValue = json['createdAt'];
    DateTime createdAt;

    if (createdAtValue is Timestamp) {
      createdAt = createdAtValue.toDate();
    } else if (createdAtValue is String) {
      createdAt = DateTime.tryParse(createdAtValue) ?? DateTime.now();
    } else {
      createdAt = DateTime.now();
    }

    return PostEntity(
      id: id,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      authorId: json['authorId'] ?? '',
      authorName: json['authorName'] ?? '',
      collegeId: json['collegeId'] ?? '',
      upvotes: (json['upvotes'] ?? 0) as int,
      commentCount: (json['commentCount'] ?? 0) as int,
      tag: json['tag'] ?? 'General',
      createdAt: createdAt,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}
