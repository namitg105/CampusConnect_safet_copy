part of 'feed_bloc.dart';

sealed class FeedEvent extends Equatable {
  const FeedEvent();

  @override
  List<Object?> get props => [];
}

/// (Re)load trending posts and the feed for the user's college.
final class FeedLoadRequested extends FeedEvent {
  final AppUser? user;
  const FeedLoadRequested(this.user);

  @override
  List<Object?> get props => [user];
}

final class FeedTabChanged extends FeedEvent {
  final String tab;
  final AppUser? user;
  const FeedTabChanged(this.tab, this.user);

  @override
  List<Object?> get props => [tab, user];
}

final class FeedTagChanged extends FeedEvent {
  final String tag;
  final AppUser? user;
  const FeedTagChanged(this.tag, this.user);

  @override
  List<Object?> get props => [tag, user];
}

/// Up (or down) arrow tapped on a post.
final class FeedVoteToggled extends FeedEvent {
  final String postId;
  final String userId;
  final bool isUpvote;
  const FeedVoteToggled({
    required this.postId,
    required this.userId,
    required this.isUpvote,
  });

  @override
  List<Object?> get props => [postId, userId, isUpvote];
}

final class FeedPostDeleted extends FeedEvent {
  final String postId;
  final AppUser author;
  const FeedPostDeleted(this.postId, this.author);

  @override
  List<Object?> get props => [postId, author];
}

/// A poll option was tapped; [poll] already contains the new vote.
final class FeedPollUpdated extends FeedEvent {
  final String postId;
  final PollData poll;
  const FeedPollUpdated(this.postId, this.poll);

  @override
  List<Object?> get props => [postId, poll];
}
