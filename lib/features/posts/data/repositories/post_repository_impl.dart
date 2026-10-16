import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/guard.dart';
import '../../domain/entities/comment_entity.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/repos/post_repo.dart';
import '../datasources/post_remote_data_source.dart';

class PostRepositoryImpl implements PostRepo {
  final PostRemoteDataSource remoteDataSource;
  const PostRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, void>> createPost(PostEntity post) =>
      guardFuture(() => remoteDataSource.createPost(post));

  @override
  Future<Either<Failure, List<PostEntity>>> getCollegeFeed(String collegeId) =>
      guardFuture(() => remoteDataSource.getCollegeFeed(collegeId));

  @override
  Future<Either<Failure, List<PostEntity>>> getTopVotedPosts(
          String collegeId) =>
      guardFuture(() => remoteDataSource.getTopVotedPosts(collegeId));

  @override
  Future<Either<Failure, PostEntity?>> getPostById(String postId) =>
      guardFuture(() => remoteDataSource.getPostById(postId));

  @override
  Future<Either<Failure, void>> deletePost(String postId) =>
      guardFuture(() => remoteDataSource.deletePost(postId));

  @override
  Future<Either<Failure, void>> upvotePost(String postId, String userId) =>
      guardFuture(() => remoteDataSource.upvotePost(postId, userId));

  @override
  Future<Either<Failure, void>> downvotePost(String postId, String userId) =>
      guardFuture(() => remoteDataSource.downvotePost(postId, userId));

  @override
  Future<Either<Failure, Map<String, int>>> getUserVotesForPosts(
          String userId, List<String> postIds) =>
      guardFuture(
          () => remoteDataSource.getUserVotesForPosts(userId, postIds));

  @override
  Future<Either<Failure, void>> updatePoll(String postId, PollData poll) =>
      guardFuture(() => remoteDataSource.updatePoll(postId, poll));

  @override
  Future<Either<Failure, void>> addComment(CommentEntity comment) =>
      guardFuture(() => remoteDataSource.addComment(comment));

  @override
  Future<Either<Failure, List<CommentEntity>>> getComments(String postId) =>
      guardFuture(() => remoteDataSource.getComments(postId));

  @override
  Future<Either<Failure, void>> deleteComment(
          String postId, String commentId, String userId) =>
      guardFuture(
          () => remoteDataSource.deleteComment(postId, commentId, userId));

  @override
  Future<Either<Failure, void>> toggleCommentLike(
          String postId, String commentId, String userId) =>
      guardFuture(
          () => remoteDataSource.toggleCommentLike(postId, commentId, userId));

  @override
  Future<Either<Failure, Map<String, bool>>> getUserLikedComments(
          String postId, String userId, List<String> commentIds) =>
      guardFuture(() =>
          remoteDataSource.getUserLikedComments(postId, userId, commentIds));
}
