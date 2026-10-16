import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/comment_entity.dart';
import '../entities/post_entity.dart';

/// Every posts operation the app needs. Implemented in the data layer.
abstract interface class PostRepo {
  Future<Either<Failure, void>> createPost(PostEntity post);

  /// Newest first.
  Future<Either<Failure, List<PostEntity>>> getCollegeFeed(String collegeId);

  /// Most upvoted first (ties: newest first).
  Future<Either<Failure, List<PostEntity>>> getTopVotedPosts(String collegeId);

  Future<Either<Failure, PostEntity?>> getPostById(String postId);

  Future<Either<Failure, void>> deletePost(String postId);

  /// Toggles the user's upvote (re-tap removes it, a downvote flips).
  Future<Either<Failure, void>> upvotePost(String postId, String userId);

  /// Toggles the user's downvote (re-tap removes it, an upvote flips).
  Future<Either<Failure, void>> downvotePost(String postId, String userId);

  /// postId -> 1 (up), -1 (down) or 0 (no vote) for the given user.
  Future<Either<Failure, Map<String, int>>> getUserVotesForPosts(
      String userId, List<String> postIds);

  Future<Either<Failure, void>> updatePoll(String postId, PollData poll);

  Future<Either<Failure, void>> addComment(CommentEntity comment);

  /// Oldest first.
  Future<Either<Failure, List<CommentEntity>>> getComments(String postId);

  /// Only the comment's author may delete it.
  Future<Either<Failure, void>> deleteComment(
      String postId, String commentId, String userId);

  Future<Either<Failure, void>> toggleCommentLike(
      String postId, String commentId, String userId);

  /// commentId -> whether the user liked it.
  Future<Either<Failure, Map<String, bool>>> getUserLikedComments(
      String postId, String userId, List<String> commentIds);
}
