import 'package:flutter_test/flutter_test.dart';
import 'package:noteswap/features/posts/domain/entities/comment_entity.dart';
import 'package:noteswap/features/posts/domain/entities/post_entity.dart';
import 'package:noteswap/features/posts/domain/repos/post_repo.dart';
import 'package:noteswap/features/posts/domain/usecases/add_comment_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/create_post_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/delete_comment_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/downvote_post_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/get_comments_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/get_feed_by_tag_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/get_feed_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/get_top_voted_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/toggle_comment_like_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/upvote_post_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/get_user_votes_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/delete_post_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/get_user_liked_comments_usecase.dart';
import 'package:noteswap/features/posts/presentation/controllers/post_controller.dart';

class FakePostRepo implements PostRepo {
  @override
  Future<void> addComment(CommentEntity comment) async {}

  @override
  Future<void> createPost(PostEntity post) async {}

  @override
  Future<void> deleteComment(String postId, String commentId, String userId) async {}

  @override
  Future<List<PostEntity>> getCollegeFeed(String collegeId) async => [];

  @override
  Future<List<PostEntity>> getCollegeFeedByTag(String collegeId, String tag) async => [];

  @override
  Future<List<CommentEntity>> getComments(String postId) async => [];

  @override
  Future<List<PostEntity>> getNewestPosts(String collegeId) async => [];

  @override
  Future<List<PostEntity>> getTopVotedPosts(String collegeId) async => [];

  @override
  Future<void> removeVote(String postId, String userId) async {}

  @override
  Future<void> upvotePost(String postId, String userId) async {}

  @override
  Future<void> downvotePost(String postId, String userId) async {}

  @override
  Future<void> toggleCommentLike(String postId, String commentId, String userId) async {}

  @override
  Future<Map<String, int>> getUserVotesForPosts(String userId, List<String> postIds) async => {};

  @override
  Future<String> uploadPostImage(String localPath, String fileName) async => '';

  @override
  Future<void> deletePost(String postId) async {}

  @override
  Future<Map<String, bool>> getUserLikedComments(
      String postId, String userId, List<String> commentIds) async => {};
}

void main() {
  group('PostController vote handling', () {
    test('toggleUpvote updates the local vote state for a post', () async {
      final fakeRepo = FakePostRepo();
      final controller = PostController(
        createPostUseCase: CreatePostUseCase(repository: fakeRepo),
        getFeedUseCase: GetFeedUseCase(repository: fakeRepo),
        getFeedByTagUseCase: GetFeedByTagUseCase(repository: fakeRepo),
        getTopVotedPostsUseCase: GetTopVotedPostsUseCase(repository: fakeRepo),
        upvotePostUseCase: UpvotePostUseCase(repository: fakeRepo),
        downvotePostUseCase: DownvotePostUseCase(repository: fakeRepo),
        addCommentUseCase: AddCommentUseCase(repository: fakeRepo),
        getCommentsUseCase: GetCommentsUseCase(repository: fakeRepo),
        deleteCommentUseCase: DeleteCommentUseCase(repository: fakeRepo),
        toggleCommentLikeUseCase: ToggleCommentLikeUseCase(repository: fakeRepo),
        getUserVotesUseCase: GetUserVotesUseCase(repository: fakeRepo),
        deletePostUseCase: DeletePostUseCase(repository: fakeRepo),
        getUserLikedCommentsUseCase: GetUserLikedCommentsUseCase(repository: fakeRepo),
      );

      await controller.toggleUpvote('post-1', 'user-1', null);

      expect(controller.getUserVote('post-1'), 1);
    });

    test('calculateVoteDelta handles upvote and downvote transitions correctly', () {
      final fakeRepo = FakePostRepo();
      final controller = PostController(
        createPostUseCase: CreatePostUseCase(repository: fakeRepo),
        getFeedUseCase: GetFeedUseCase(repository: fakeRepo),
        getFeedByTagUseCase: GetFeedByTagUseCase(repository: fakeRepo),
        getTopVotedPostsUseCase: GetTopVotedPostsUseCase(repository: fakeRepo),
        upvotePostUseCase: UpvotePostUseCase(repository: fakeRepo),
        downvotePostUseCase: DownvotePostUseCase(repository: fakeRepo),
        addCommentUseCase: AddCommentUseCase(repository: fakeRepo),
        getCommentsUseCase: GetCommentsUseCase(repository: fakeRepo),
        deleteCommentUseCase: DeleteCommentUseCase(repository: fakeRepo),
        toggleCommentLikeUseCase: ToggleCommentLikeUseCase(repository: fakeRepo),
        getUserVotesUseCase: GetUserVotesUseCase(repository: fakeRepo),
        deletePostUseCase: DeletePostUseCase(repository: fakeRepo),
        getUserLikedCommentsUseCase: GetUserLikedCommentsUseCase(repository: fakeRepo),
      );

      expect(controller.calculateVoteDelta(previousVote: 0, isUpvote: true), 1);
      expect(controller.calculateVoteDelta(previousVote: 1, isUpvote: true), -1);
      expect(controller.calculateVoteDelta(previousVote: -1, isUpvote: true), 2);
      expect(controller.calculateVoteDelta(previousVote: 0, isUpvote: false), -1);
      expect(controller.calculateVoteDelta(previousVote: 1, isUpvote: false), -2);
      expect(controller.calculateVoteDelta(previousVote: -1, isUpvote: false), 1);
    });

    test('toggleCommentLike updates the local comment-like state', () async {
      final fakeRepo = FakePostRepo();
      final controller = PostController(
        createPostUseCase: CreatePostUseCase(repository: fakeRepo),
        getFeedUseCase: GetFeedUseCase(repository: fakeRepo),
        getFeedByTagUseCase: GetFeedByTagUseCase(repository: fakeRepo),
        getTopVotedPostsUseCase: GetTopVotedPostsUseCase(repository: fakeRepo),
        upvotePostUseCase: UpvotePostUseCase(repository: fakeRepo),
        downvotePostUseCase: DownvotePostUseCase(repository: fakeRepo),
        addCommentUseCase: AddCommentUseCase(repository: fakeRepo),
        getCommentsUseCase: GetCommentsUseCase(repository: fakeRepo),
        deleteCommentUseCase: DeleteCommentUseCase(repository: fakeRepo),
        toggleCommentLikeUseCase: ToggleCommentLikeUseCase(repository: fakeRepo),
        getUserVotesUseCase: GetUserVotesUseCase(repository: fakeRepo),
        deletePostUseCase: DeletePostUseCase(repository: fakeRepo),
        getUserLikedCommentsUseCase: GetUserLikedCommentsUseCase(repository: fakeRepo),
      );

      await controller.toggleCommentLike('post-1', 'comment-1', 'user-1');

      expect(controller.getCommentLikeState('comment-1'), true);
    });
  });
}
