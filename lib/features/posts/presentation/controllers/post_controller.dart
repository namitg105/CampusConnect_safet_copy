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
import 'package:noteswap/features/posts/domain/usecases/get_user_votes_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/delete_post_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/get_user_liked_comments_usecase.dart';

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
  final GetUserVotesUseCase getUserVotesUseCase;
  final DeletePostUseCase deletePostUseCase;
  final GetUserLikedCommentsUseCase getUserLikedCommentsUseCase;

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
    required this.getUserVotesUseCase,
    required this.deletePostUseCase,
    required this.getUserLikedCommentsUseCase,
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
  final RxList<String> availableTags = <String>['All', 'Badminton', 'Seniors', 'ExamHelp', 'General', 'Events', 'Study'].obs;

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

      // Extract unique tags from unfiltered collegeFeed
      final List<String> currentTags = ['All', 'Badminton', 'Seniors', 'ExamHelp', 'General', 'Events', 'Study'];
      for (final post in collegeFeed) {
        if (post.tag.isNotEmpty && !currentTags.contains(post.tag)) {
          currentTags.add(post.tag);
        }
      }
      availableTags.assignAll(currentTags);

      if (selectedTag.value != 'All') {
        collegeFeed = collegeFeed
            .where((post) => post.tag == selectedTag.value)
            .toList();
      }

      posts.value = collegeFeed;

      // Fetch user's votes for these posts to keep client state in sync
      if (user.uid.isNotEmpty && collegeFeed.isNotEmpty) {
        final postIds = collegeFeed.map((post) => post.id).toList();
        final votes = await getUserVotesUseCase.call(user.uid, postIds);
        userVotes.addAll(votes);
      }
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
    String? imagePath,
    String? imageName,
  }) async {
    if (title.trim().isEmpty || body.trim().isEmpty) {
      errorMessage.value = 'Title and body cannot be empty.';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      String? imageUrl;
      if (imagePath != null && imageName != null) {
        imageUrl = await createPostUseCase.repository.uploadPostImage(imagePath, imageName);
      }

      final newPost = PostEntity(
        id: '',
        title: title.trim(),
        body: body.trim(),
        authorId: author.uid,
        authorName: author.name.isNotEmpty 
            ? author.name 
            : (author.email.contains('@') ? author.email.split('@').first : author.email),
        collegeId: author.collegeId,
        upvotes: 0,
        commentCount: 0,
        tag: tag,
        createdAt: DateTime.now(),
        imageUrl: imageUrl,
      );

      await createPostUseCase.call(newPost);
      await loadFeed(author);
    } catch (e) {
      errorMessage.value = 'Unable to create post: $e';
    } finally {
      isLoading.value = false;
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

    errorMessage.value = '';

    final previousVote = userVotes[postId] ?? 0;
    final nextVote = previousVote == 1 ? 0 : 1;
    print("[PostController] toggleUpvote: postId=$postId, previousVote=$previousVote, nextVote=$nextVote");

    votingPostIds.add(postId);

    try {
      await upvotePostUseCase.call(postId, userId);
      userVotes[postId] = nextVote;
      _updatePostVoteCount(postId, calculateVoteDelta(previousVote: previousVote, isUpvote: true));
    } catch (e, stack) {
      print("Error in toggleUpvote: $e\n$stack");
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

    errorMessage.value = '';

    final previousVote = userVotes[postId] ?? 0;
    final nextVote = previousVote == -1 ? 0 : -1;
    print("[PostController] toggleDownvote: postId=$postId, previousVote=$previousVote, nextVote=$nextVote");

    votingPostIds.add(postId);

    try {
      await downvotePostUseCase.call(postId, userId);
      userVotes[postId] = nextVote;
      _updatePostVoteCount(postId, calculateVoteDelta(previousVote: previousVote, isUpvote: false));
    } catch (e, stack) {
      print("Error in toggleDownvote: $e\n$stack");
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
    final updatedCount = (currentPost.upvotes + delta).toInt();
    posts[index] = currentPost.copyWith(upvotes: updatedCount);
  }

  int getUserVote(String postId) => userVotes[postId] ?? 0;

  Future<List<CommentEntity>> loadComments(String postId, String userId) async {
    try {
      final fetchedComments = await getCommentsUseCase.call(postId);
      comments.value = fetchedComments;

      // Load liked states for these comments
      if (userId.isNotEmpty && fetchedComments.isNotEmpty) {
        final commentIds = fetchedComments.map((c) => c.id).toList();
        final likedStates = await getUserLikedCommentsUseCase.call(postId, userId, commentIds);
        likedComments.addAll(likedStates);
      }

      return fetchedComments;
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
    String? parentId,
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
        parentId: parentId,
      );
      await addCommentUseCase.call(comment);
      await loadComments(postId, authorId);
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
      final isLiked = !(likedComments[commentId] ?? false);
      likedComments[commentId] = isLiked;

      // Update comment likes count locally in comments list
      final index = comments.indexWhere((c) => c.id == commentId);
      if (index != -1) {
        final currentComment = comments[index];
        final currentLikes = currentComment.likes;
        comments[index] = CommentEntity(
          id: currentComment.id,
          postId: currentComment.postId,
          authorId: currentComment.authorId,
          authorName: currentComment.authorName,
          text: currentComment.text,
          createdAt: currentComment.createdAt,
          parentId: currentComment.parentId,
          likes: isLiked ? currentLikes + 1 : (currentLikes - 1 < 0 ? 0 : currentLikes - 1),
        );
      }
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
      await loadComments(postId, userId);
      if (author != null) {
        await loadFeed(author);
      }
    } catch (e) {
      errorMessage.value = 'Unable to delete comment: $e';
    }
  }

  Future<void> removePost(String postId, AppUser author) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      await deletePostUseCase.call(postId);
      await loadFeed(author);
    } catch (e) {
      errorMessage.value = 'Failed to delete post: $e';
    } finally {
      isLoading.value = false;
    }
  }
}

