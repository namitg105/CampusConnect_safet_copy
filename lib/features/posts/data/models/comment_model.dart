import '../../domain/entities/comment_entity.dart';

/// Firestore mapping for `posts/{postId}/comments/{commentId}`.
///
/// ```json
/// {
///   "id": "c1", "postId": "p1", "authorId": "uid1", "authorName": "Namit",
///   "text": "Count me in!", "createdAt": "2026-10-16T09:30:00.000",
///   "parentId": null, "likes": 3
/// }
/// ```
class CommentModel extends CommentEntity {
  const CommentModel({
    required super.id,
    required super.postId,
    required super.authorId,
    required super.authorName,
    required super.text,
    required super.createdAt,
    super.parentId,
    super.likes,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json, String id) {
    return CommentModel(
      id: id,
      postId: json['postId'] ?? '',
      authorId: json['authorId'] ?? '',
      authorName: json['authorName'] ?? '',
      text: json['text'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      parentId: json['parentId'],
      likes: ((json['likes'] ?? 0) as num).toInt(),
    );
  }

  static Map<String, dynamic> toJson(CommentEntity comment) {
    return {
      'postId': comment.postId,
      'authorId': comment.authorId,
      'authorName': comment.authorName,
      'text': comment.text,
      'createdAt': comment.createdAt.toIso8601String(),
      if (comment.parentId != null) 'parentId': comment.parentId,
      'likes': comment.likes,
    };
  }
}
