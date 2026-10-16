import '../entities/post_entity.dart';

/// "This user acts on this post" (votes).
class PostUserParams {
  final String postId;
  final String userId;
  const PostUserParams({required this.postId, required this.userId});
}

/// "This user acts on this comment" (delete, like).
class CommentUserParams {
  final String postId;
  final String commentId;
  final String userId;
  const CommentUserParams({
    required this.postId,
    required this.commentId,
    required this.userId,
  });
}

class UserVotesParams {
  final String userId;
  final List<String> postIds;
  const UserVotesParams({required this.userId, required this.postIds});
}

class LikedCommentsParams {
  final String postId;
  final String userId;
  final List<String> commentIds;
  const LikedCommentsParams({
    required this.postId,
    required this.userId,
    required this.commentIds,
  });
}

class UpdatePollParams {
  final String postId;
  final PollData poll;
  const UpdatePollParams({required this.postId, required this.poll});
}
