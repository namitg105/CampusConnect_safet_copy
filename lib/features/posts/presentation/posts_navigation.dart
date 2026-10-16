import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../core/navigation/app_navigator.dart';
import '../../auth/domain/entities/app_user.dart';
import '../domain/entities/post_entity.dart';
import 'bloc/comments/comments_bloc.dart';
import 'bloc/create_post/create_post_bloc.dart';
import 'bloc/feed/feed_bloc.dart';
import 'pages/all_announcements_screen.dart';
import 'pages/all_posts_screen.dart';
import 'pages/create_post_page.dart';
import 'pages/post_detail_page.dart';

/// Opening a posts screen = pushing a route on the root navigator. Routes
/// are not children of the screen that opened them, so the blocs they need
/// are handed over here with `BlocProvider.value` (shared) or created fresh.
abstract final class PostsNavigation {
  /// Shares [feedBloc] when given; otherwise the new route gets its own
  /// FeedBloc, which is closed automatically when the route is popped.
  static BlocProvider<FeedBloc> _feedProvider(FeedBloc? feedBloc) =>
      feedBloc != null
          ? BlocProvider.value(value: feedBloc)
          : BlocProvider(create: (_) => sl<FeedBloc>());

  static Future<void> openPostDetail({
    FeedBloc? feedBloc,
    required PostEntity post,
    AppUser? currentUser,
  }) {
    return AppNavigator.push(MultiBlocProvider(
      providers: [
        _feedProvider(feedBloc),
        BlocProvider(create: (_) => sl<CommentsBloc>()),
      ],
      child: PostDetailPage(post: post, currentUser: currentUser),
    ));
  }

  static Future<void> openAllPosts({
    required FeedBloc feedBloc,
    required String title,
    required List<PostEntity> Function(List<PostEntity> posts) postsSelector,
    required AppUser currentUser,
  }) {
    return AppNavigator.push(BlocProvider.value(
      value: feedBloc,
      child: AllPostsScreen(
        title: title,
        postsSelector: postsSelector,
        currentUser: currentUser,
      ),
    ));
  }

  static Future<void> openAllAnnouncements({
    FeedBloc? feedBloc,
    required AppUser currentUser,
  }) {
    return AppNavigator.push(MultiBlocProvider(
      providers: [_feedProvider(feedBloc)],
      child: AllAnnouncementsScreen(currentUser: currentUser),
    ));
  }

  /// Completes with `true` when a post was created, so the caller can
  /// refresh its feed.
  static Future<bool?> openCreatePost({required AppUser currentUser}) {
    return AppNavigator.push<bool>(BlocProvider(
      create: (_) => sl<CreatePostBloc>(),
      child: CreatePostPage(currentUser: currentUser),
    ));
  }
}

/// Convenience for widgets below a `FeedBloc`.
extension FeedBlocContext on BuildContext {
  FeedBloc get feedBloc => read<FeedBloc>();
}
