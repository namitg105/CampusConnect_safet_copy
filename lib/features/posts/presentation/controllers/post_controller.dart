import 'package:get/get.dart';
import 'package:noteswap/features/auth/domain/entities/app_user.dart';
import 'package:noteswap/features/posts/domain/entities/comment_entity.dart';
import 'package:noteswap/features/posts/domain/entities/post_entity.dart';
import 'package:noteswap/features/posts/domain/usecases/add_comment_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/create_post_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/delete_comment_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/downvote_post_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/get_comments_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/get_feed_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/get_feed_by_tag_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/get_top_voted_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/toggle_comment_like_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/upvote_post_usecase.dart';

class PostController extends GetxController {
  final CreatePostUseCase createPostUseCase;
  final GetFeedUseCase getFeedUseCase;
  final GetFeedByTagUseCase getFeedByTagUseCase;
  final GetTopVotedPostsUseCase getTopVotedPostsUseCase;
  final UpvotePostUseCase upvotePostUseCase;
  final DownvotePostUseCase downvotePostUseCase;
  final AddCommentUseCase addCommentUseCase;
  final GetCommentsUseCase getCommentsUseCase;
  final DeleteCommentUseCase deleteCommentUseCase;
  final ToggleCommentLikeUseCase toggleCommentLikeUseCase;

  PostController({
    required this.createPostUseCase,
    required this.getFeedUseCase,
    required this.getFeedByTagUseCase,
    required this.getTopVotedPostsUseCase,
    required this.upvotePostUseCase,
    required this.downvotePostUseCase,
    required this.addCommentUseCase,
    required this.getCommentsUseCase,
    required this.deleteCommentUseCase,
    required this.toggleCommentLikeUseCase,
  });

  final RxList<PostEntity> posts = <PostEntity>[].obs;
  final RxList<CommentEntity> comments = <CommentEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString selectedTab = 'Newest'.obs;
  final RxString selectedTag = 'All'.obs;
  final RxMap<String, int> userVotes = <String, int>{}.obs;
  final RxMap<String, bool> likedComments = <String, bool>{}.obs;
  final RxSet<String> votingPostIds = <String>{}.obs;

  Future<void> loadFeed(AppUser? user) async {
    if (user == null || user.collegeId.isEmpty) {
      errorMessage.value = 'College domain is missing.\nPlease login again.';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      List<PostEntity> collegeFeed;

      if (selectedTab.value == 'Top Voted') {
        collegeFeed = await getTopVotedPostsUseCase.call(user.collegeId);
      } else {
        collegeFeed = await getFeedUseCase.call(user.collegeId);
      }

      if (selectedTag.value != 'All') {
        collegeFeed = collegeFeed
            .where((post) => post.tag == selectedTag.value)
            .toList();
      }

      posts.value = collegeFeed;
    } catch (e) {
      errorMessage.value = 'Failed to load feed: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void changeTab(String tabName, AppUser? user) {
    selectedTab.value = tabName;
    loadFeed(user);
  }

  void filterByTag(String tag, AppUser? user) {
    selectedTag.value = tag;
    loadFeed(user);
  }

  Future<void> addPost({
    required String title,
    required String body,
    required AppUser author,
    required String tag,
  }) async {
    if (title.trim().isEmpty || body.trim().isEmpty) {
      errorMessage.value = 'Title and body cannot be empty.';
      return;
    }

    final newPost = PostEntity(
      id: '',
      title: title.trim(),
      body: body.trim(),
      authorId: author.uid,
      authorName: author.name.isNotEmpty ? author.name : author.email,
      collegeId: author.collegeId,
      upvotes: 0,
      commentCount: 0,
      tag: tag,
      createdAt: DateTime.now(),
    );

    try {
      await createPostUseCase.call(newPost);
      await loadFeed(author);
    } catch (e) {
      errorMessage.value = 'Unable to create post: $e';
    }
  }

  Future<void> toggleUpvote(String postId, String userId, AppUser? author) async {
    if (userId.isEmpty) {
      errorMessage.value = 'You need to be signed in to vote.';
      return;
    }

    if (votingPostIds.contains(postId)) {
      return;
    }

    final previousVote = userVotes[postId] ?? 0;
    final nextVote = previousVote == 1 ? 0 : 1;

    votingPostIds.add(postId);

    try {
      await upvotePostUseCase.call(postId, userId);
      userVotes[postId] = nextVote;
      if (author != null) {
        await loadFeed(author);
      }
    } catch (e) {
      errorMessage.value = 'Error voting: $e';
    } finally {
      votingPostIds.remove(postId);
    }
  }

  Future<void> toggleDownvote(String postId, String userId, AppUser? author) async {
    if (userId.isEmpty) {
      errorMessage.value = 'You need to be signed in to vote.';
      return;
    }

    if (votingPostIds.contains(postId)) {
      return;
    }

    final previousVote = userVotes[postId] ?? 0;
    final nextVote = previousVote == -1 ? 0 : -1;

    votingPostIds.add(postId);

    try {
      await downvotePostUseCase.call(postId, userId);
      userVotes[postId] = nextVote;
      _updatePostVoteCount(postId, calculateVoteDelta(previousVote: previousVote, isUpvote: false));
      if (author != null) {
        await loadFeed(author);
      }
    } catch (e) {
      errorMessage.value = 'Error voting: $e';
    } finally {
      votingPostIds.remove(postId);
    }
  }

  int calculateVoteDelta({required int previousVote, required bool isUpvote}) {
    final nextVote = isUpvote ? (previousVote == 1 ? 0 : 1) : (previousVote == -1 ? 0 : -1);
    return nextVote - previousVote;
  }

  void _updatePostVoteCount(String postId, int delta) {
    final index = posts.indexWhere((post) => post.id == postId);
    if (index == -1) {
      return;
    }

    final currentPost = posts[index];
    final updatedCount = (currentPost.upvotes + delta).clamp(0, double.infinity).toInt();
    posts[index] = currentPost.copyWith(upvotes: updatedCount);
  }

  int getUserVote(String postId) => userVotes[postId] ?? 0;

  Future<List<CommentEntity>> loadComments(String postId) async {
    try {
      comments.value = await getCommentsUseCase.call(postId);
      return comments;
    } catch (e) {
      errorMessage.value = 'Unable to load comments: $e';
      return [];
    }
  }

  Future<void> submitComment({
    required String postId,
    required String authorId,
    required String authorName,
    required String text,
    AppUser? author,
  }) async {
    if (text.trim().isEmpty || authorId.isEmpty) {
      return;
    }

    try {
      final comment = CommentEntity(
        id: '',
        postId: postId,
        authorId: authorId,
        authorName: authorName,
        text: text.trim(),
        createdAt: DateTime.now(),
      );
      await addCommentUseCase.call(comment);
      await loadComments(postId);
      if (author != null) {
        await loadFeed(author);
      }
    } catch (e) {
      errorMessage.value = 'Unable to add comment: $e';
    }
  }

  Future<void> toggleCommentLike(String postId, String commentId, String userId) async {
    try {
      await toggleCommentLikeUseCase.call(postId, commentId, userId);
      likedComments[commentId] = !(likedComments[commentId] ?? false);
    } catch (e) {
      errorMessage.value = 'Unable to like comment: $e';
    }
  }

  bool getCommentLikeState(String commentId) => likedComments[commentId] ?? false;

  Future<void> removeComment({
    required String postId,
    required String commentId,
    required String userId,
    AppUser? author,
  }) async {
    try {
      await deleteCommentUseCase.call(postId, commentId, userId);
      await loadComments(postId);
      if (author != null) {
        await loadFeed(author);
      }
    } catch (e) {
      errorMessage.value = 'Unable to delete comment: $e';
    }
  }
}

