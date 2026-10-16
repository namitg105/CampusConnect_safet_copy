part of 'feed_bloc.dart';

const List<String> kDefaultFeedTags = [
  'All',
  'Badminton',
  'Seniors',
  'ExamHelp',
  'General',
  'Events',
  'Study',
];

final class FeedState extends Equatable {
  final List<PostEntity> posts;
  final List<PostEntity> trendingPosts;
  final bool isLoading;
  final String errorMessage;
  final String selectedTab; // 'Newest' | 'Top Voted'
  final String selectedTag; // 'All' or a tag
  final List<String> availableTags;

  /// postId -> 1 (upvoted), -1 (downvoted), 0 (no vote).
  final Map<String, int> userVotes;

  /// Posts with a vote request in flight (taps are ignored meanwhile).
  final Set<String> votingPostIds;

  const FeedState({
    this.posts = const [],
    this.trendingPosts = const [],
    this.isLoading = false,
    this.errorMessage = '',
    this.selectedTab = 'Newest',
    this.selectedTag = 'All',
    this.availableTags = kDefaultFeedTags,
    this.userVotes = const {},
    this.votingPostIds = const {},
  });

  int voteOf(String postId) => userVotes[postId] ?? 0;
  bool isUpvoted(String postId) => voteOf(postId) == 1;
  bool isDownvoted(String postId) => voteOf(postId) == -1;

  FeedState copyWith({
    List<PostEntity>? posts,
    List<PostEntity>? trendingPosts,
    bool? isLoading,
    String? errorMessage,
    String? selectedTab,
    String? selectedTag,
    List<String>? availableTags,
    Map<String, int>? userVotes,
    Set<String>? votingPostIds,
  }) {
    return FeedState(
      posts: posts ?? this.posts,
      trendingPosts: trendingPosts ?? this.trendingPosts,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedTab: selectedTab ?? this.selectedTab,
      selectedTag: selectedTag ?? this.selectedTag,
      availableTags: availableTags ?? this.availableTags,
      userVotes: userVotes ?? this.userVotes,
      votingPostIds: votingPostIds ?? this.votingPostIds,
    );
  }

  @override
  List<Object?> get props => [
        posts,
        trendingPosts,
        isLoading,
        errorMessage,
        selectedTab,
        selectedTag,
        availableTags,
        userVotes,
        votingPostIds,
      ];
}

/// How much a post's score changes when the user taps up/down, given
/// their current vote. E.g. downvoted (-1) then tapping up => +2.
int calculateVoteDelta({required int previousVote, required bool isUpvote}) {
  final nextVote =
      isUpvote ? (previousVote == 1 ? 0 : 1) : (previousVote == -1 ? 0 : -1);
  return nextVote - previousVote;
}
