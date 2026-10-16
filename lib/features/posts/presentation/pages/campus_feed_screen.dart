import 'package:noteswap/core/navigation/app_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:noteswap/features/auth/domain/entities/app_user.dart';
import 'package:noteswap/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:noteswap/features/home/presentation/bloc/main_nav_bloc.dart';
import 'package:noteswap/core/di/injection.dart';
import 'package:noteswap/features/posts/presentation/bloc/feed/feed_bloc.dart';
import 'package:noteswap/features/posts/presentation/posts_navigation.dart';
import 'package:noteswap/features/posts/presentation/pages/user_profile_screen.dart';
import 'package:noteswap/features/posts/presentation/widgets/post_card.dart';
import 'package:noteswap/core/theme/theme_context.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:noteswap/features/profile/presentation/pages/profile_settings_page.dart';
import 'package:noteswap/utils/time_formatter.dart';
import 'package:noteswap/features/posts/domain/entities/post_entity.dart';

class CampusFeedScreen extends StatefulWidget {
  const CampusFeedScreen({Key? key}) : super(key: key);

  @override
  State<CampusFeedScreen> createState() => _CampusFeedScreenState();
}

class _CampusFeedScreenState extends State<CampusFeedScreen> {
  // One feed per screen, like the old per-screen PostController.
  final FeedBloc _feedBloc = sl<FeedBloc>();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    // Load feed when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState is Authenticated) {
        _feedBloc.add(FeedLoadRequested(authState.user));
      }
    });
  }

  @override
  void dispose() {
    _feedBloc.close();
    super.dispose();
  }

  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! Authenticated) {
          return Scaffold(
            body: Center(
              child: Text(
                'Please login to view the feed',
                style: TextStyle(
                  color: context.isLightMode
                      ? Colors.black
                      : Colors.white,
                ),
              ),
            ),
          );
        }

        final currentUser = authState.user;
        final isLightMode = context.isLightMode;

        // Custom colors matching the uniConnect Figma specification
        final backgroundColor =
            isLightMode ? const Color(0xFFF4F1FC) : const Color(0xFF121214);
        final cardColor = isLightMode ? Colors.white : const Color(0xFF1E1E22);
        final textColor = isLightMode ? const Color(0xFF1A1A1E) : Colors.white;
        final subTextColor =
            isLightMode ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF);
        final brandColor = const Color(0xFF6139ED);

        final greeting = _getTimeBasedGreeting();
        final cleanName = currentUser.name.isNotEmpty
            ? currentUser.name
            : (currentUser.email.contains('@')
                ? currentUser.email.split('@').first
                : currentUser.email);

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            backgroundColor: backgroundColor,
            elevation: 0,
            title: Text(
              'uniConnect',
              style: TextStyle(
                color: brandColor,
                fontWeight: FontWeight.bold,
                fontSize: 22,
                letterSpacing: 0.5,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: () {
                  AppNavigator.push(ProfileSettingsPage());
                },
                icon: Icon(Icons.person, color: textColor),
              ),
            ],
          ),
          body: BlocBuilder<FeedBloc, FeedState>(
            bloc: _feedBloc,
            builder: (context, feed) {
            if (feed.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF6139ED)),
              );
            }

            if (feed.errorMessage.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      feed.errorMessage,
                      style: TextStyle(color: textColor),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () =>
                          _feedBloc.add(FeedLoadRequested(currentUser)),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                // 1. Greet row and Page Title
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$greeting, $cleanName 👋',
                        style: TextStyle(
                          fontSize: 14,
                          color: subTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Home Feed',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. Search Bar (no filter icon)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color:
                          isLightMode ? Colors.white : const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isLightMode
                            ? const Color(0xFFEBEBF0)
                            : const Color(0xFF2D2D2D),
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/posts_screen_assets/serach_icon.png',
                          width: 20,
                          height: 20,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            onChanged: (val) => setState(() => _searchQuery = val),
                            decoration: InputDecoration(
                              hintText: 'Search posts, people, topics...',
                              hintStyle: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                height: 1.0,
                                color: isLightMode
                                    ? const Color(0xFF1A1A2E).withOpacity(0.5)
                                    : Colors.white.withOpacity(0.5),
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              height: 1.0,
                              color: isLightMode
                                  ? const Color(0xFF1A1A2E)
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_searchQuery.isNotEmpty) ...[
                  // Search Results — use a shrink-wrapped ListView.builder for
                  // efficiency when there are many matching posts
                  _buildHeaderSection('Search Results'),
                  const SizedBox(height: 12),
                  (() {
                    final query = _searchQuery.trim().toLowerCase();
                    final filteredPosts = _feedBloc.state.posts.where((post) {
                      final titleMatch =
                          post.title.toLowerCase().contains(query);
                      final bodyMatch = post.body.toLowerCase().contains(query);
                      return titleMatch || bodyMatch;
                    }).toList();

                    if (filteredPosts.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              "No posts found matching '$_searchQuery'",
                              style:
                                  TextStyle(color: subTextColor, fontSize: 13),
                            ),
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredPosts.length,
                      itemBuilder: (context, index) {
                        final post = filteredPosts[index];
                        return PostCard(
                          post: post,
                          onTap: () => PostsNavigation.openPostDetail(
                                feedBloc: _feedBloc,
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
                          onUpvote: () => _feedBloc.add(FeedVoteToggled(
                              postId: post.id,
                              userId: currentUser.uid,
                              isUpvote: true)),
                          onDownvote: () => _feedBloc.add(FeedVoteToggled(
                              postId: post.id,
                              userId: currentUser.uid,
                              isUpvote: false)),
                          onPollChanged: (poll) =>

                              _feedBloc.add(FeedPollUpdated(post.id, poll)),
                          onDelete: post.authorId == currentUser.uid
                              ? () => _confirmDeletePost(post.id, currentUser)
                              : null,
                          isLightMode: isLightMode,
                          isUpvoted: _feedBloc.state.voteOf(post.id) == 1,
                          isDownvoted:
                              _feedBloc.state.voteOf(post.id) == -1,
                        );
                      },
                    );
                  }()),
                ] else ...[
                  // 3. Trending Discussions Block
                  _buildHeaderSection(
                    'Trending Discussions',
                    onTap: () => PostsNavigation.openAllPosts(
                          feedBloc: _feedBloc,
                          title: 'Trending Discussions',
                          postsSelector: (posts) => posts.toList()
                            ..sort((a, b) => b.upvotes.compareTo(a.upvotes)),
                          currentUser: currentUser,
                          ),
                  ),
                  const SizedBox(height: 12),
                  if (_feedBloc.state.trendingPosts.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            'No trending posts yet',
                            style: TextStyle(color: subTextColor, fontSize: 13),
                          ),
                        ),
                      ),
                    )
                  else
                    Column(
                      children:
                          _feedBloc.state.trendingPosts.take(3).map((post) {
                        return PostCard(
                          post: post,
                          onTap: () => PostsNavigation.openPostDetail(
                                feedBloc: _feedBloc,
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
                          onUpvote: () => _feedBloc.add(FeedVoteToggled(
                              postId: post.id,
                              userId: currentUser.uid,
                              isUpvote: true)),
                          onDownvote: () => _feedBloc.add(FeedVoteToggled(
                              postId: post.id,
                              userId: currentUser.uid,
                              isUpvote: false)),
                          onPollChanged: (poll) =>

                              _feedBloc.add(FeedPollUpdated(post.id, poll)),
                          onDelete: post.authorId == currentUser.uid
                              ? () => _confirmDeletePost(post.id, currentUser)
                              : null,
                          isLightMode: isLightMode,
                          isUpvoted: _feedBloc.state.voteOf(post.id) == 1,
                          isDownvoted:
                              _feedBloc.state.voteOf(post.id) == -1,
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 24),

                  // 4. Announcements Block
                  _buildHeaderSection(
                    'Announcements',
                    onTap: () => PostsNavigation.openAllAnnouncements(
                          feedBloc: _feedBloc,
                          currentUser: currentUser,
                          ),
                  ),
                  const SizedBox(height: 12),
                  (() {
                    final announcements = _feedBloc.state.posts
                        .where(
                            (post) => post.tag.toLowerCase() == 'announcement')
                        .toList();

                    if (announcements.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              'No announcements yet.',
                              style:
                                  TextStyle(color: subTextColor, fontSize: 13),
                            ),
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: announcements.take(3).map((post) {
                        return PostCard(
                          post: post,
                          onTap: () => PostsNavigation.openPostDetail(
                                feedBloc: _feedBloc,
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
                          onUpvote: () => _feedBloc.add(FeedVoteToggled(
                              postId: post.id,
                              userId: currentUser.uid,
                              isUpvote: true)),
                          onDownvote: () => _feedBloc.add(FeedVoteToggled(
                              postId: post.id,
                              userId: currentUser.uid,
                              isUpvote: false)),
                          onPollChanged: (poll) =>

                              _feedBloc.add(FeedPollUpdated(post.id, poll)),
                          onDelete: post.authorId == currentUser.uid
                              ? () => _confirmDeletePost(post.id, currentUser)
                              : null,
                          isLightMode: isLightMode,
                          isUpvoted: _feedBloc.state.voteOf(post.id) == 1,
                          isDownvoted:
                              _feedBloc.state.voteOf(post.id) == -1,
                        );
                      }).toList(),
                    );
                  }()),
                  const SizedBox(height: 24),

                  // 5. Latest Posts Block
                  _buildHeaderSection(
                    'Latest Posts',
                    onTap: () => PostsNavigation.openAllPosts(
                          feedBloc: _feedBloc,
                          title: 'Latest Posts',
                          postsSelector: (posts) => posts.toList()
                            ..sort(
                                (a, b) => b.createdAt.compareTo(a.createdAt)),
                          currentUser: currentUser,
                          ),
                  ),
                  const SizedBox(height: 12),
                  if (_feedBloc.state.posts.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            'No posts yet. Be the first to share!',
                            style: TextStyle(color: subTextColor, fontSize: 13),
                          ),
                        ),
                      ),
                    )
                  else
                    Column(
                      children: _feedBloc.state.posts.take(3).map((post) {
                        return PostCard(
                          post: post,
                          onTap: () => PostsNavigation.openPostDetail(
                                feedBloc: _feedBloc,
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
                          onUpvote: () => _feedBloc.add(FeedVoteToggled(
                              postId: post.id,
                              userId: currentUser.uid,
                              isUpvote: true)),
                          onDownvote: () => _feedBloc.add(FeedVoteToggled(
                              postId: post.id,
                              userId: currentUser.uid,
                              isUpvote: false)),
                          onPollChanged: (poll) =>

                              _feedBloc.add(FeedPollUpdated(post.id, poll)),
                          onDelete: post.authorId == currentUser.uid
                              ? () => _confirmDeletePost(post.id, currentUser)
                              : null,
                          isLightMode: isLightMode,
                          isUpvoted: _feedBloc.state.voteOf(post.id) == 1,
                          isDownvoted:
                              _feedBloc.state.voteOf(post.id) == -1,
                        );
                      }).toList(),
                    ),
                ],
                const SizedBox(height: 100), // extra padding for nav bar
              ],
            );
          }),
          // Consistent pill-shaped nav bar — same style as main_page.dart
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: SizedBox(
                height: 70,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.topCenter,
                  children: [
                    Positioned.fill(
                      top: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F1FE),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0F172A).withOpacity(0.06),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: BlocBuilder<MainNavBloc, MainNavState>(
                          builder: (context, nav) {
                          final idx = nav.currentIndex;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _FeedNavIcon(
                                assetPath: 'assets/community/home_nav.png',
                                label: 'Home',
                                isSelected: idx == 0,
                                onTap: () {
                                  context.read<MainNavBloc>().add(const MainNavTabSelected(0));
                                  Navigator.of(context).maybePop();
                                },
                              ),
                              _FeedNavIcon(
                                assetPath: 'assets/community/comm_nav.png',
                                label: 'Community',
                                isSelected: idx == 1,
                                onTap: () {
                                  context.read<MainNavBloc>().add(const MainNavTabSelected(1));
                                  Navigator.of(context).maybePop();
                                },
                              ),
                              // Gap for floating + button
                              const SizedBox(width: 56),
                              _FeedNavIcon(
                                assetPath: 'assets/community/msg_nav.png',
                                label: 'Messages',
                                isSelected: idx == 2,
                                onTap: () {
                                  context.read<MainNavBloc>().add(const MainNavTabSelected(2));
                                  Navigator.of(context).maybePop();
                                },
                              ),
                              _FeedNavIcon(
                                assetPath: 'assets/community/prof_nav.png',
                                label: 'Profile',
                                isSelected: idx == 3,
                                onTap: () {
                                  context.read<MainNavBloc>().add(const MainNavTabSelected(3));
                                  Navigator.of(context).maybePop();
                                },
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                    // Floating + button
                    Positioned(
                      top: 0,
                      child: GestureDetector(
                        onTap: () async {
                          final created = await PostsNavigation.openCreatePost(
                              currentUser: currentUser);
                          if (created == true) {
                            _feedBloc.add(FeedLoadRequested(currentUser));
                          }
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: brandColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: brandColor.withOpacity(0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.add_rounded,
                              color: Colors.white, size: 26),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderSection(String title, {VoidCallback? onTap}) {
    Widget titleWidget;
    if (title == 'Trending Discussions') {
      titleWidget = Image.asset(
        'assets/posts_screen_assets/trending_discussions_bar.png',
        height: 22,
        fit: BoxFit.contain,
      );
    } else if (title == 'Announcements') {
      titleWidget = Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/posts_screen_assets/announcement_icon.png',
            width: 24,
            height: 24,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w400,
              height: 1.5, // 33px / 22px = 1.5
              letterSpacing: 0,
              color: const Color(0xFF1E1F24),
            ),
          ),
        ],
      );
    } else if (title == 'Latest Posts') {
      titleWidget = Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/posts_screen_assets/latest_posts_timer.png',
            width: 24,
            height: 24,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w400,
              height: 1.5, // 33px / 22px = 1.5
              letterSpacing: 0,
              color: const Color(0xFF1E1F24),
            ),
          ),
        ],
      );
    } else {
      titleWidget = Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          titleWidget,
          GestureDetector(
            onTap: onTap,
            child: const Text(
              'See all >',
              style: TextStyle(
                color: Color(0xFF6139ED),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingDiscussionCard(
      PostEntity initialPost,
      Color cardColor,
      Color textColor,
      Color subTextColor,
      Color brandColor,
      bool isLightMode,
      AppUser currentUser) {
    // Resolve post dynamically to keep reactive updates in sync
    final postIndex =
        _feedBloc.state.trendingPosts.indexWhere((p) => p.id == initialPost.id);
    final post =
        postIndex != -1 ? _feedBloc.state.trendingPosts[postIndex] : initialPost;
    final userVote = _feedBloc.state.voteOf(post.id);
    final timeStr = formatTimeAgo(post.createdAt);
    final groupName = 'r/${post.tag.replaceAll(" ", "")}';

    return GestureDetector(
      onTap: () => PostsNavigation.openPostDetail(
            feedBloc: _feedBloc,
            post: post,
            currentUser: currentUser,
          ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isLightMode
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
          border: Border.all(
            color: isLightMode ? Colors.grey[100]! : Colors.grey[850]!,
            width: 0.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Vote Counter Block
            Column(
              children: [
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: () => _feedBloc.add(FeedVoteToggled(
                              postId: post.id,
                              userId: currentUser.uid,
                              isUpvote: true)),
                  child: Icon(
                    Icons.arrow_upward,
                    size: 16,
                    color: userVote == 1 ? brandColor : subTextColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  post.upvotes.toString(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => _feedBloc.add(FeedVoteToggled(
                              postId: post.id,
                              userId: currentUser.uid,
                              isUpvote: false)),
                  child: Icon(
                    Icons.arrow_downward,
                    size: 16,
                    color: userVote == -1 ? Colors.redAccent : subTextColor,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),

            // Right content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Topic Badge & Time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: brandColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          post.tag,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: brandColor,
                          ),
                        ),
                      ),
                      Text(
                        timeStr,
                        style: TextStyle(
                          fontSize: 10,
                          color: subTextColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Post Title
                  Text(
                    post.title,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      height: 1.45,
                      color: textColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Post Body Snippet
                  Text(
                    post.body,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                      color: subTextColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // Subtopic label & replies counter
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        groupName,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: subTextColor,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: brandColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.chat_bubble_outline,
                                size: 10, color: brandColor),
                            const SizedBox(width: 4),
                            Text(
                              post.commentCount.toString(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: brandColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementCard(String title, String description, String date,
      Color bgColor, Color themeColor, IconData icon) {
    return Container(
      width: 170,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: themeColor, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              description,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: Colors.grey[800],
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.calendar_month, size: 11, color: themeColor),
              const SizedBox(width: 4),
              Text(
                date,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: themeColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected,
      Color brandColor, Color? unselectedColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isSelected ? brandColor : unselectedColor,
          size: 24,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? brandColor : unselectedColor,
          ),
        ),
      ],
    );
  }

  void _confirmDeletePost(String postId, AppUser currentUser) {
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
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
                _feedBloc.add(FeedPostDeleted(postId, currentUser));
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

/// Nav-bar icon matching the pill-shaped bar in main_page.dart
class _FeedNavIcon extends StatelessWidget {
  final String assetPath;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FeedNavIcon({
    required this.assetPath,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color brandPrimary = Color(0xFF6366F1);
    const Color textMuted = Color(0xFF64748B);
    final currentColor = isSelected ? brandPrimary : textMuted;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: brandPrimary.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              assetPath,
              width: 20,
              height: 20,
              color: currentColor,
              errorBuilder: (_, __, ___) => Icon(
                Icons.circle,
                size: 20,
                color: currentColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: currentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
