part of 'comments_bloc.dart';

sealed class CommentsEvent extends Equatable {
  const CommentsEvent();

  @override
  List<Object?> get props => [];
}

final class CommentsLoadRequested extends CommentsEvent {
  final String postId;
  final String userId;
  const CommentsLoadRequested({required this.postId, required this.userId});

  @override
  List<Object?> get props => [postId, userId];
}

final class CommentSubmitted extends CommentsEvent {
  final String postId;
  final String authorId;
  final String authorName;
  final String text;
  final String? parentId;
  const CommentSubmitted({
    required this.postId,
    required this.authorId,
    required this.authorName,
    required this.text,
    this.parentId,
  });

  @override
  List<Object?> get props => [postId, authorId, authorName, text, parentId];
}

final class CommentDeleted extends CommentsEvent {
  final String postId;
  final String commentId;
  final String userId;
  const CommentDeleted({
    required this.postId,
    required this.commentId,
    required this.userId,
  });

  @override
  List<Object?> get props => [postId, commentId, userId];
}

final class CommentLikeToggled extends CommentsEvent {
  final String postId;
  final String commentId;
  final String userId;
  const CommentLikeToggled({
    required this.postId,
    required this.commentId,
    required this.userId,
  });

  @override
  List<Object?> get props => [postId, commentId, userId];
}
