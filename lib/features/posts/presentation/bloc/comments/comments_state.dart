part of 'comments_bloc.dart';

final class CommentsState extends Equatable {
  final List<CommentEntity> comments;

  /// commentId -> liked by the current user.
  final Map<String, bool> likedComments;
  final String errorMessage;

  /// Increases after each successful new comment, so the page can refresh
  /// the feed's comment counters.
  final int submittedCount;

  const CommentsState({
    this.comments = const [],
    this.likedComments = const {},
    this.errorMessage = '',
    this.submittedCount = 0,
  });

  bool isLiked(String commentId) => likedComments[commentId] ?? false;

  CommentsState copyWith({
    List<CommentEntity>? comments,
    Map<String, bool>? likedComments,
    String? errorMessage,
    int? submittedCount,
  }) {
    return CommentsState(
      comments: comments ?? this.comments,
      likedComments: likedComments ?? this.likedComments,
      errorMessage: errorMessage ?? this.errorMessage,
      submittedCount: submittedCount ?? this.submittedCount,
    );
  }

  @override
  List<Object?> get props =>
      [comments, likedComments, errorMessage, submittedCount];
}
