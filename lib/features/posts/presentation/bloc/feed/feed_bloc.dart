import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../auth/domain/entities/app_user.dart';
import '../../../domain/entities/post_entity.dart';
import '../../../domain/usecases/delete_post_usecase.dart';
import '../../../domain/usecases/downvote_post_usecase.dart';
import '../../../domain/usecases/get_feed_usecase.dart';
import '../../../domain/usecases/get_top_voted_usecase.dart';
import '../../../domain/usecases/get_user_votes_usecase.dart';
import '../../../domain/usecases/post_params.dart';
import '../../../domain/usecases/update_poll_usecase.dart';
import '../../../domain/usecases/upvote_post_usecase.dart';

part 'feed_event.dart';
part 'feed_state.dart';

/// Campus feed: trending + main list, tab/tag filters, votes, polls and
/// deleting your own posts. Replaces the feed half of `PostController`.
class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final GetFeedUseCase _getFeed;
  final GetTopVotedPostsUseCase _getTopVoted;
  final GetUserVotesUseCase _getUserVotes;
  final UpvotePostUseCase _upvote;
  final DownvotePostUseCase _downvote;
  final DeletePostUseCase _deletePost;
  final UpdatePollUseCase _updatePoll;

  FeedBloc({
    required GetFeedUseCase getFeed,
    required GetTopVotedPostsUseCase getTopVoted,
    required GetUserVotesUseCase getUserVotes,
    required UpvotePostUseCase upvote,
    required DownvotePostUseCase downvote,
    required DeletePostUseCase deletePost,
    required UpdatePollUseCase updatePoll,
  })  : _getFeed = getFeed,
        _getTopVoted = getTopVoted,
        _getUserVotes = getUserVotes,
        _upvote = upvote,
        _downvote = downvote,
        _deletePost = deletePost,
        _updatePoll = updatePoll,
        super(const FeedState()) {
    on<FeedLoadRequested>((event, emit) => _load(event.user, emit));
    on<FeedTabChanged>((event, emit) {
      emit(state.copyWith(selectedTab: event.tab));
      return _load(event.user, emit);
    });
    on<FeedTagChanged>((event, emit) {
      emit(state.copyWith(selectedTag: event.tag));
      return _load(event.user, emit);
    });
    on<FeedVoteToggled>(_onVoteToggled);
    on<FeedPostDeleted>(_onPostDeleted);
    on<FeedPollUpdated>(_onPollUpdated);
  }

  Future<void> _load(AppUser? user, Emitter<FeedState> emit) async {
    if (user == null || user.collegeId.isEmpty) {
      emit(state.copyWith(
          errorMessage: 'College domain is missing.\nPlease login again.'));
      return;
    }
    emit(state.copyWith(isLoading: true, errorMessage: ''));

    // Trending is a nice-to-have: on failure keep what we had.
    final trending = await _getTopVoted(user.collegeId);
    trending.fold(
      (failure) => debugPrint('Failed to load trending posts: ${failure.message}'),
      (posts) => emit(state.copyWith(trendingPosts: posts.take(3).toList())),
    );

    final feedResult = state.selectedTab == 'Top Voted'
        ? await _getTopVoted(user.collegeId)
        : await _getFeed(user.collegeId);

    await feedResult.fold(
      (failure) async => emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load feed: ${failure.message}',
      )),
      (feed) async {
        // Tags = defaults + any new tag seen in the (unfiltered) feed.
        final tags = [...kDefaultFeedTags];
        for (final post in feed) {
          if (post.tag.isNotEmpty && !tags.contains(post.tag)) tags.add(post.tag);
        }
        final visible = state.selectedTag == 'All'
            ? feed
            : feed.where((p) => p.tag == state.selectedTag).toList();
        emit(state.copyWith(availableTags: tags, posts: visible));

        // Sync which arrows are highlighted for this user.
        if (user.uid.isNotEmpty && visible.isNotEmpty) {
          final votes = await _getUserVotes(UserVotesParams(
            userId: user.uid,
            postIds: visible.map((p) => p.id).toList(),
          ));
          votes.fold(
            (failure) => emit(state.copyWith(
                errorMessage: 'Failed to load feed: ${failure.message}')),
            (map) => emit(state.copyWith(userVotes: {...state.userVotes, ...map})),
          );
        }
        emit(state.copyWith(isLoading: false));
      },
    );
  }

  Future<void> _onVoteToggled(
    FeedVoteToggled event,
    Emitter<FeedState> emit,
  ) async {
    if (event.userId.isEmpty) {
      emit(state.copyWith(errorMessage: 'You need to be signed in to vote.'));
      return;
    }
    if (state.votingPostIds.contains(event.postId)) return;

    final previousVote = state.voteOf(event.postId);
    emit(state.copyWith(
      errorMessage: '',
      votingPostIds: {...state.votingPostIds, event.postId},
    ));

    final params = PostUserParams(postId: event.postId, userId: event.userId);
    final result =
        event.isUpvote ? await _upvote(params) : await _downvote(params);

    result.fold(
      (failure) =>
          emit(state.copyWith(errorMessage: 'Error voting: ${failure.message}')),
      (_) {
        final delta = calculateVoteDelta(
            previousVote: previousVote, isUpvote: event.isUpvote);
        PostEntity bump(PostEntity p) => p.id == event.postId
            ? p.copyWith(upvotes: p.upvotes + delta)
            : p;
        emit(state.copyWith(
          userVotes: {...state.userVotes, event.postId: previousVote + delta},
          posts: state.posts.map(bump).toList(),
          trendingPosts: state.trendingPosts.map(bump).toList(),
        ));
      },
    );
    emit(state.copyWith(
      votingPostIds: {...state.votingPostIds}..remove(event.postId),
    ));
  }

  Future<void> _onPostDeleted(
    FeedPostDeleted event,
    Emitter<FeedState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: ''));
    final result = await _deletePost(event.postId);
    await result.fold(
      (failure) async => emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to delete post: ${failure.message}',
      )),
      (_) => _load(event.author, emit),
    );
  }

  Future<void> _onPollUpdated(
    FeedPollUpdated event,
    Emitter<FeedState> emit,
  ) async {
    PostEntity withPoll(PostEntity p) =>
        p.id == event.postId ? p.copyWith(poll: event.poll) : p;
    emit(state.copyWith(
      posts: state.posts.map(withPoll).toList(),
      trendingPosts: state.trendingPosts.map(withPoll).toList(),
    ));
    // Background sync, like before: the UI already shows the vote.
    final result = await _updatePoll(
        UpdatePollParams(postId: event.postId, poll: event.poll));
    result.fold(
      (failure) => debugPrint('Poll sync failed: ${failure.message}'),
      (_) {},
    );
  }
}
