import 'package:noteswap/features/posts/domain/entities/comment_entity.dart';
import 'package:noteswap/features/posts/domain/entities/post_entity.dart';

abstract class PostRepo {
  Future<void> createPost(PostEntity post);
  Future<List<PostEntity>> getCollegeFeed(String collegeId);
  Future<List<PostEntity>> getCollegeFeedByTag(String collegeId, String tag);
  Future<List<PostEntity>> getTopVotedPosts(String collegeId);
  Future<List<PostEntity>> getNewestPosts(String collegeId);
  Future<void> upvotePost(String postId, String userId);
  Future<void> downvotePost(String postId, String userId);
  Future<void> removeVote(String postId, String userId);
  Future<void> addComment(CommentEntity comment);
  Future<List<CommentEntity>> getComments(String postId);
  Future<void> deleteComment(String postId, String commentId, String userId);
  Future<void> toggleCommentLike(String postId, String commentId, String userId);
  Future<Map<String, int>> getUserVotesForPosts(String userId, List<String> postIds);
  Future<String> uploadPostImage(String localPath, String fileName);
  Future<void> deletePost(String postId);
  Future<Map<String, bool>> getUserLikedComments(String postId, String userId, List<String> commentIds);
}
