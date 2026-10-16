import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/comment_entity.dart';
import '../../../domain/usecases/add_comment_usecase.dart';
import '../../../domain/usecases/delete_comment_usecase.dart';
import '../../../domain/usecases/get_comments_usecase.dart';
import '../../../domain/usecases/get_user_liked_comments_usecase.dart';
import '../../../domain/usecases/post_params.dart';
import '../../../domain/usecases/toggle_comment_like_usecase.dart';

part 'comments_event.dart';
part 'comments_state.dart';

/// Comments of one post (one bloc per open PostDetailPage).
class CommentsBloc extends Bloc<CommentsEvent, CommentsState> {
  final GetCommentsUseCase _getComments;
  final GetUserLikedCommentsUseCase _getLiked;
  final AddCommentUseCase _addComment;
  final DeleteCommentUseCase _deleteComment;
  final ToggleCommentLikeUseCase _toggleLike;

  CommentsBloc({
    required GetCommentsUseCase getComments,
    required GetUserLikedCommentsUseCase getUserLikedComments,
    required AddCommentUseCase addComment,
    required DeleteCommentUseCase deleteComment,
    required ToggleCommentLikeUseCase toggleCommentLike,
  })  : _getComments = getComments,
        _getLiked = getUserLikedComments,
        _addComment = addComment,
        _deleteComment = deleteComment,
        _toggleLike = toggleCommentLike,
        super(const CommentsState()) {
    on<CommentsLoadRequested>(
        (event, emit) => _load(event.postId, event.userId, emit));
    on<CommentSubmitted>(_onSubmitted);
    on<CommentDeleted>(_onDeleted);
    on<CommentLikeToggled>(_onLikeToggled);
  }

  Future<void> _load(
      String postId, String userId, Emitter<CommentsState> emit) async {
    final result = await _getComments(postId);
    await result.fold(
      (failure) async => emit(state.copyWith(
          errorMessage: 'Unable to load comments: ${failure.message}')),
      (comments) async {
        emit(state.copyWith(comments: comments));
        if (userId.isEmpty || comments.isEmpty) return;
        final liked = await _getLiked(LikedCommentsParams(
          postId: postId,
          userId: userId,
          commentIds: comments.map((c) => c.id).toList(),
        ));
        liked.fold(
          (failure) => emit(state.copyWith(
              errorMessage: 'Unable to load comments: ${failure.message}')),
          (map) => emit(state.copyWith(
              likedComments: {...state.likedComments, ...map})),
        );
      },
    );
  }

  Future<void> _onSubmitted(
    CommentSubmitted event,
    Emitter<CommentsState> emit,
  ) async {
    if (event.text.trim().isEmpty || event.authorId.isEmpty) return;

    final result = await _addComment(CommentEntity(
      id: '',
      postId: event.postId,
      authorId: event.authorId,
      authorName: event.authorName,
      text: event.text.trim(),
      createdAt: DateTime.now(),
      parentId: event.parentId,
    ));
    await result.fold(
      (failure) async => emit(state.copyWith(
          errorMessage: 'Unable to add comment: ${failure.message}')),
      (_) async {
        await _load(event.postId, event.authorId, emit);
        emit(state.copyWith(submittedCount: state.submittedCount + 1));
      },
    );
  }

  Future<void> _onDeleted(
    CommentDeleted event,
    Emitter<CommentsState> emit,
  ) async {
    final result = await _deleteComment(CommentUserParams(
      postId: event.postId,
      commentId: event.commentId,
      userId: event.userId,
    ));
    await result.fold(
      (failure) async => emit(state.copyWith(
          errorMessage: 'Unable to delete comment: ${failure.message}')),
      (_) => _load(event.postId, event.userId, emit),
    );
  }

  Future<void> _onLikeToggled(
    CommentLikeToggled event,
    Emitter<CommentsState> emit,
  ) async {
    final result = await _toggleLike(CommentUserParams(
      postId: event.postId,
      commentId: event.commentId,
      userId: event.userId,
    ));
    result.fold(
      (failure) => emit(state.copyWith(
          errorMessage: 'Unable to like comment: ${failure.message}')),
      (_) {
        final isLiked = !state.isLiked(event.commentId);
        emit(state.copyWith(
          likedComments: {...state.likedComments, event.commentId: isLiked},
          comments: state.comments.map((c) {
            if (c.id != event.commentId) return c;
            final likes = isLiked ? c.likes + 1 : (c.likes - 1 < 0 ? 0 : c.likes - 1);
            return c.copyWith(likes: likes);
          }).toList(),
        ));
      },
    );
  }
}
