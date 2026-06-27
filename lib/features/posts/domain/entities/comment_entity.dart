class CommentEntity {
  final String id;
  final String postId;
  final String authorId;
  final String authorName;
  final String text;
  final DateTime createdAt;
  final String? parentId;
  final int likes;

  CommentEntity({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorName,
    required this.text,
    required this.createdAt,
    this.parentId,
    this.likes = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'authorId': authorId,
      'authorName': authorName,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
      if (parentId != null) 'parentId': parentId,
      'likes': likes,
    };
  }

  factory CommentEntity.fromJson(Map<String, dynamic> json, String id) {
    return CommentEntity(
      id: id,
      postId: json['postId'] ?? '',
      authorId: json['authorId'] ?? '',
      authorName: json['authorName'] ?? '',
      text: json['text'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      parentId: json['parentId'],
      likes: json['likes'] ?? 0,
    );
  }
}
