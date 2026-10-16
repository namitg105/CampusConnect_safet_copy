import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noteswap/core/navigation/app_navigator.dart';
import 'package:noteswap/core/theme/theme_context.dart';
import 'package:noteswap/features/auth/domain/entities/app_user.dart';
import 'package:noteswap/features/posts/domain/entities/post_entity.dart';
import 'package:noteswap/features/posts/presentation/bloc/feed/feed_bloc.dart';
import 'package:noteswap/features/posts/presentation/pages/user_profile_screen.dart';
import 'package:noteswap/features/posts/presentation/posts_navigation.dart';
import 'package:noteswap/features/posts/presentation/widgets/post_card.dart';

class AllPostsScreen extends StatelessWidget {
  final String title;

  /// Picks and orders the posts to show from the feed's current posts.
  final List<PostEntity> Function(List<PostEntity> posts) postsSelector;
  final AppUser currentUser;

  const AllPostsScreen({
    super.key,
    required this.title,
    required this.postsSelector,
    required this.currentUser,
  });

  void _confirmDeletePost(BuildContext context, String postId) {
    final feedBloc = context.feedBloc;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Post'),
          content: const Text(
              'Are you sure you want to delete this post? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                feedBloc.add(FeedPostDeleted(postId, currentUser));
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeedBloc, FeedState>(builder: (context, feed) {
      final isLightMode = context.isLightMode;

      final backgroundColor =
          isLightMode ? const Color(0xFFF4F1FC) : const Color(0xFF121214);
      final textColor = isLightMode ? const Color(0xFF1A1A1E) : Colors.white;
      final subTextColor =
          isLightMode ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF);

      // Dynamically select and sort the posts to display
      final displayedPosts = postsSelector(feed.posts);

      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: isLightMode ? Colors.white : const Color(0xFF1E1E22),
          elevation: 0.5,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: textColor),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: displayedPosts.isEmpty
            ? Center(
                child: Text(
                  'No posts available',
                  style: TextStyle(color: subTextColor, fontSize: 14),
                ),
              )
            : ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: displayedPosts.length,
                itemBuilder: (context, index) {
                  final post = displayedPosts[index];
                  return PostCard(
                    post: post,
                    onTap: () => PostsNavigation.openPostDetail(
                      feedBloc: context.feedBloc,
                      post: post,
                      currentUser: currentUser,
                    ),
                    onProfileTap: () => AppNavigator.push(UserProfileScreen(
                        user: AppUser(
                      uid: post.authorId,
                      email: '',
                      name: post.authorName,
                      collegeId: post.collegeId,
                    ))),
                    onUpvote: () => context.feedBloc.add(FeedVoteToggled(
                      postId: post.id,
                      userId: currentUser.uid,
                      isUpvote: true,
                    )),
                    onDownvote: () => context.feedBloc.add(FeedVoteToggled(
                      postId: post.id,
                      userId: currentUser.uid,
                      isUpvote: false,
                    )),
                    onPollChanged: (poll) =>
                        context.feedBloc.add(FeedPollUpdated(post.id, poll)),
                    onDelete: post.authorId == currentUser.uid
                        ? () => _confirmDeletePost(context, post.id)
                        : null,
                    isUpvoted: feed.isUpvoted(post.id),
                    isDownvoted: feed.isDownvoted(post.id),
                    isLightMode: isLightMode,
                  );
                },
              ),
      );
    });
  }
}
