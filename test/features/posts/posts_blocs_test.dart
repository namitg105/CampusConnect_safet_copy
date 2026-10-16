import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:noteswap/core/error/failures.dart';
import 'package:noteswap/features/auth/domain/entities/app_user.dart';
import 'package:noteswap/features/posts/data/models/post_model.dart';
import 'package:noteswap/features/posts/domain/entities/comment_entity.dart';
import 'package:noteswap/features/posts/domain/entities/post_entity.dart';
import 'package:noteswap/features/posts/domain/repos/post_repo.dart';
import 'package:noteswap/features/posts/domain/usecases/add_comment_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/create_post_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/delete_comment_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/delete_post_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/downvote_post_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/get_comments_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/get_feed_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/get_top_voted_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/get_user_liked_comments_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/get_user_votes_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/toggle_comment_like_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/update_poll_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/upvote_post_usecase.dart';
import 'package:noteswap/features/posts/presentation/bloc/comments/comments_bloc.dart';
import 'package:noteswap/features/posts/presentation/bloc/create_post/create_post_bloc.dart';
import 'package:noteswap/features/posts/presentation/bloc/feed/feed_bloc.dart';

PostEntity _post(String id, {String tag = 'General', int upvotes = 0}) =>
    PostEntity(
      id: id,
      title: 't$id',
      body: 'b$id',
      authorId: 'author',
      authorName: 'Author',
      collegeId: 'nith.ac.in',
      upvotes: upvotes,
      commentCount: 0,
      tag: tag,
      createdAt: DateTime(2026),
    );

CommentEntity _comment(String id, {int likes = 0}) => CommentEntity(
      id: id,
      postId: 'p1',
      authorId: 'u1',
      authorName: 'U',
      text: 'hi',
      createdAt: DateTime(2026),
      likes: likes,
    );

const _user = AppUser(
    uid: 'u1', email: 'u1@nith.ac.in', name: 'U', collegeId: 'nith.ac.in');

/// In-memory PostRepo; each field can be swapped per test.
class FakePostRepo implements PostRepo {
  List<PostEntity> feed = [];
  List<PostEntity> topVoted = [];
  List<CommentEntity> comments = [];
  Map<String, int> votes = {};
  Failure? failVotes;
  /// When set, votes stay "on the network" until it completes.
  Completer<void>? voteGate;
  Failure? failDeleteComment;
  final List<String> calls = [];
  PostEntity? created;

  @override
  Future<Either<Failure, void>> createPost(PostEntity post) async {
    created = post;
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<PostEntity>>> getCollegeFeed(String c) async =>
      Right(feed);

  @override
  Future<Either<Failure, List<PostEntity>>> getTopVotedPosts(String c) async =>
      Right(topVoted);

  @override
  Future<Either<Failure, PostEntity?>> getPostById(String id) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> deletePost(String id) async {
    calls.add('deletePost:$id');
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> upvotePost(String p, String u) async {
    calls.add('upvote:$p');
    await voteGate?.future;
    return failVotes != null ? Left(failVotes!) : const Right(null);
  }

  @override
  Future<Either<Failure, void>> downvotePost(String p, String u) async {
    calls.add('downvote:$p');
    return failVotes != null ? Left(failVotes!) : const Right(null);
  }

  @override
  Future<Either<Failure, Map<String, int>>> getUserVotesForPosts(
          String u, List<String> ids) async =>
      Right(votes);

  @override
  Future<Either<Failure, void>> updatePoll(String p, PollData poll) async {
    calls.add('poll:$p');
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> addComment(CommentEntity c) async {
    comments = [...comments, _comment('new')];
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<CommentEntity>>> getComments(String p) async =>
      Right(comments);

  @override
  Future<Either<Failure, void>> deleteComment(
      String p, String c, String userId) async {
    calls.add('deleteComment:$c:$userId');
    return failDeleteComment != null
        ? Left(failDeleteComment!)
        : const Right(null);
  }

  @override
  Future<Either<Failure, void>> toggleCommentLike(
          String p, String c, String u) async =>
      const Right(null);

  @override
  Future<Either<Failure, Map<String, bool>>> getUserLikedComments(
          String p, String u, List<String> ids) async =>
      const Right({});
}

FeedBloc _feedBloc(FakePostRepo r) => FeedBloc(
      getFeed: GetFeedUseCase(repository: r),
      getTopVoted: GetTopVotedPostsUseCase(repository: r),
      getUserVotes: GetUserVotesUseCase(repository: r),
      upvote: UpvotePostUseCase(repository: r),
      downvote: DownvotePostUseCase(repository: r),
      deletePost: DeletePostUseCase(repository: r),
      updatePoll: UpdatePollUseCase(repository: r),
    );

CommentsBloc _commentsBloc(FakePostRepo r) => CommentsBloc(
      getComments: GetCommentsUseCase(repository: r),
      getUserLikedComments: GetUserLikedCommentsUseCase(repository: r),
      addComment: AddCommentUseCase(repository: r),
      deleteComment: DeleteCommentUseCase(repository: r),
      toggleCommentLike: ToggleCommentLikeUseCase(repository: r),
    );

/// Waits until [bloc] has processed everything queued so far.
Future<void> _settle() => Future<void>.delayed(const Duration(milliseconds: 10));

void main() {
  late FakePostRepo repo;
  setUp(() => repo = FakePostRepo());

  group('calculateVoteDelta', () {
    test('handles upvote and downvote transitions correctly', () {
      expect(calculateVoteDelta(previousVote: 0, isUpvote: true), 1);
      expect(calculateVoteDelta(previousVote: 1, isUpvote: true), -1);
      expect(calculateVoteDelta(previousVote: -1, isUpvote: true), 2);
      expect(calculateVoteDelta(previousVote: 0, isUpvote: false), -1);
      expect(calculateVoteDelta(previousVote: 1, isUpvote: false), -2);
      expect(calculateVoteDelta(previousVote: -1, isUpvote: false), 1);
    });
  });

  group('FeedBloc', () {
    test('load fills posts, top-3 trending, extra tags and votes', () async {
      repo
        ..feed = [_post('a', tag: 'Hackathon'), _post('b')]
        ..topVoted = [_post('1'), _post('2'), _post('3'), _post('4')]
        ..votes = {'a': 1};
      final bloc = _feedBloc(repo)..add(const FeedLoadRequested(_user));
      await _settle();

      expect(bloc.state.isLoading, isFalse);
      expect(bloc.state.posts.map((p) => p.id), ['a', 'b']);
      expect(bloc.state.trendingPosts.map((p) => p.id), ['1', '2', '3']);
      expect(bloc.state.availableTags, contains('Hackathon'));
      expect(bloc.state.isUpvoted('a'), isTrue);
      await bloc.close();
    });

    test('missing college id shows an error and does not load', () async {
      final bloc = _feedBloc(repo)
        ..add(const FeedLoadRequested(
            AppUser(uid: 'u', email: 'e', name: 'n')));
      await _settle();
      expect(bloc.state.errorMessage, contains('College domain is missing'));
      expect(bloc.state.isLoading, isFalse);
      await bloc.close();
    });

    test('tag filter keeps only matching posts', () async {
      repo.feed = [_post('a', tag: 'Events'), _post('b', tag: 'Study')];
      final bloc = _feedBloc(repo)..add(const FeedTagChanged('Study', _user));
      await _settle();
      expect(bloc.state.selectedTag, 'Study');
      expect(bloc.state.posts.map((p) => p.id), ['b']);
      await bloc.close();
    });

    test('toggleUpvote updates the local vote state and score', () async {
      repo.feed = [_post('post-1', upvotes: 5)];
      final bloc = _feedBloc(repo)..add(const FeedLoadRequested(_user));
      await _settle();

      bloc.add(const FeedVoteToggled(
          postId: 'post-1', userId: 'u1', isUpvote: true));
      await _settle();
      expect(bloc.state.voteOf('post-1'), 1);
      expect(bloc.state.posts.single.upvotes, 6);
      expect(bloc.state.votingPostIds, isEmpty);

      // Switching to a downvote moves the score by 2.
      bloc.add(const FeedVoteToggled(
          postId: 'post-1', userId: 'u1', isUpvote: false));
      await _settle();
      expect(bloc.state.voteOf('post-1'), -1);
      expect(bloc.state.posts.single.upvotes, 4);
      await bloc.close();
    });

    test('a second tap while a vote is in flight is ignored', () async {
      repo.voteGate = Completer<void>();
      final bloc = _feedBloc(repo)
        ..add(const FeedVoteToggled(postId: 'p', userId: 'u1', isUpvote: true))
        ..add(const FeedVoteToggled(postId: 'p', userId: 'u1', isUpvote: true));
      await _settle();
      expect(bloc.state.votingPostIds, {'p'});
      repo.voteGate!.complete();
      await _settle();
      expect(repo.calls.where((c) => c == 'upvote:p'), hasLength(1));
      expect(bloc.state.voteOf('p'), 1);
      await bloc.close();
    });

    test('signed-out vote and failed vote set an error, vote unchanged',
        () async {
      final bloc = _feedBloc(repo)
        ..add(const FeedVoteToggled(postId: 'p', userId: '', isUpvote: true));
      await _settle();
      expect(bloc.state.errorMessage, 'You need to be signed in to vote.');

      repo.failVotes = const ServerFailure('offline');
      bloc.add(
          const FeedVoteToggled(postId: 'p', userId: 'u1', isUpvote: true));
      await _settle();
      expect(bloc.state.errorMessage, 'Error voting: offline');
      expect(bloc.state.voteOf('p'), 0);
      await bloc.close();
    });

    test('deleting a post calls the repo and reloads', () async {
      repo.feed = [_post('keep')];
      final bloc = _feedBloc(repo)..add(const FeedPostDeleted('gone', _user));
      await _settle();
      expect(repo.calls, contains('deletePost:gone'));
      expect(bloc.state.posts.map((p) => p.id), ['keep']);
      await bloc.close();
    });

    test('poll update changes the post locally and syncs it', () async {
      repo.feed = [_post('p')];
      final bloc = _feedBloc(repo)..add(const FeedLoadRequested(_user));
      await _settle();
      const poll = PollData(question: 'Q', options: [
        PollOption(text: 'Yes', votes: ['u1'])
      ]);
      bloc.add(const FeedPollUpdated('p', poll));
      await _settle();
      expect(bloc.state.posts.single.poll, same(poll));
      expect(repo.calls, contains('poll:p'));
      await bloc.close();
    });
  });

  group('PollData.toggleVote', () {
    const poll = PollData(question: 'Q', options: [
      PollOption(text: 'A', votes: ['x']),
      PollOption(text: 'B', votes: ['me']),
    ]);

    test('picking another option moves the vote', () {
      final next = poll.toggleVote(optionText: 'A', uid: 'me');
      expect(next.options[0].votes, ['x', 'me']);
      expect(next.options[1].votes, isEmpty);
    });

    test('picking the same option removes the vote', () {
      final next = poll.toggleVote(optionText: 'B', uid: 'me');
      expect(next.totalVotes, 1);
    });
  });

  group('CommentsBloc', () {
    test('toggleCommentLike updates the local like state and count',
        () async {
      repo.comments = [_comment('comment-1', likes: 2)];
      final bloc = _commentsBloc(repo)
        ..add(const CommentsLoadRequested(postId: 'p1', userId: 'u1'));
      await _settle();
      bloc.add(const CommentLikeToggled(
          postId: 'p1', commentId: 'comment-1', userId: 'u1'));
      await _settle();
      expect(bloc.state.isLiked('comment-1'), isTrue);
      expect(bloc.state.comments.single.likes, 3);
      await bloc.close();
    });

    test('submitting reloads comments and bumps submittedCount', () async {
      final bloc = _commentsBloc(repo)
        ..add(const CommentSubmitted(
            postId: 'p1', authorId: 'u1', authorName: 'U', text: ' hello '));
      await _settle();
      expect(bloc.state.comments.map((c) => c.id), ['new']);
      expect(bloc.state.submittedCount, 1);
      await bloc.close();
    });

    test('empty comment is ignored', () async {
      final bloc = _commentsBloc(repo)
        ..add(const CommentSubmitted(
            postId: 'p1', authorId: 'u1', authorName: 'U', text: '   '));
      await _settle();
      expect(bloc.state.submittedCount, 0);
      await bloc.close();
    });

    test('delete passes the current user id (regression)', () async {
      final bloc = _commentsBloc(repo)
        ..add(const CommentDeleted(
            postId: 'p1', commentId: 'c9', userId: 'u1'));
      await _settle();
      expect(repo.calls, contains('deleteComment:c9:u1'));
      await bloc.close();
    });

    test('failed delete shows an error', () async {
      repo.failDeleteComment =
          const ServerFailure('You can only delete your own comments');
      final bloc = _commentsBloc(repo)
        ..add(const CommentDeleted(
            postId: 'p1', commentId: 'c9', userId: 'u2'));
      await _settle();
      expect(bloc.state.errorMessage,
          'Unable to delete comment: You can only delete your own comments');
      await bloc.close();
    });
  });

  group('CreatePostBloc', () {
    test('empty body fails validation without saving', () async {
      final bloc = CreatePostBloc(
          createPost: CreatePostUseCase(repository: repo))
        ..add(const CreatePostSubmitted(
            title: 'T', body: '  ', author: _user, tag: 'General'));
      await _settle();
      expect(bloc.state.status, CreatePostStatus.failure);
      expect(repo.created, isNull);
      await bloc.close();
    });

    test('success saves a trimmed post authored by the user', () async {
      final bloc = CreatePostBloc(
          createPost: CreatePostUseCase(repository: repo))
        ..add(const CreatePostSubmitted(
            title: ' Hi ', body: ' Body ', author: _user, tag: 'Events'));
      await expectLater(
        bloc.stream.map((s) => s.status),
        emitsInOrder([CreatePostStatus.submitting, CreatePostStatus.success]),
      );
      expect(repo.created!.title, 'Hi');
      expect(repo.created!.authorId, 'u1');
      expect(repo.created!.collegeId, 'nith.ac.in');
      expect(repo.created!.imageUrl, isNull);
      await bloc.close();
    });
  });

  group('PostModel', () {
    test('round-trips through Firestore JSON incl. poll', () {
      const poll = PollData(question: 'Q', options: [
        PollOption(text: 'A', votes: ['u1'])
      ]);
      final post = _post('p').copyWith(poll: poll);
      final json = PostModel.toJson(post);
      final back = PostModel.fromJson(json, 'p');
      expect(back.title, post.title);
      expect(back.createdAt, post.createdAt);
      expect(back.poll!.options.single.votes, ['u1']);
    });

    test('old poll option key "option" is still read', () {
      final back = PostModel.fromJson({
        'poll': {
          'question': 'Q',
          'options': [
            {'option': 'Legacy', 'votes': []}
          ],
        }
      }, 'p');
      expect(back.poll!.options.single.text, 'Legacy');
      expect(back.tag, 'General');
    });
  });
}
