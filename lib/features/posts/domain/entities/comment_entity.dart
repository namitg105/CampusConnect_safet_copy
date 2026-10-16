/// A comment (or reply, when [parentId] is set) on a post.
class CommentEntity {
  final String id;
  final String postId;
  final String authorId;
  final String authorName;
  final String text;
  final DateTime createdAt;
  final String? parentId;
  final int likes;

  const CommentEntity({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorName,
    required this.text,
    required this.createdAt,
    this.parentId,
    this.likes = 0,
  });

  CommentEntity copyWith({int? likes}) {
    return CommentEntity(
      id: id,
      postId: postId,
      authorId: authorId,
      authorName: authorName,
      text: text,
      createdAt: createdAt,
      parentId: parentId,
      likes: likes ?? this.likes,
    );
  }
}
