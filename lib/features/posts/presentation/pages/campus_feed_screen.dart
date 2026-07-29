import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:noteswap/features/auth/domain/entities/app_user.dart';
import 'package:noteswap/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:noteswap/features/auth/presentation/cubits/auth_states.dart';
import 'package:noteswap/features/home/presentation/pages/main_page.dart';
import 'package:noteswap/features/posts/presentation/controllers/post_controller.dart';
import 'package:noteswap/features/posts/presentation/pages/create_post_page.dart';
import 'package:noteswap/features/posts/presentation/pages/post_detail_page.dart';
import 'package:noteswap/features/posts/presentation/pages/user_profile_screen.dart';
import 'package:noteswap/features/posts/presentation/widgets/post_card.dart';
import 'package:noteswap/features/posts/presentation/pages/all_posts_screen.dart';
import 'package:noteswap/features/posts/presentation/pages/all_announcements_screen.dart';
import 'package:noteswap/ViewModels/DarkModeViewModels.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:noteswap/features/posts/data/post_repo_impl.dart';
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
import 'package:noteswap/utils/time_formatter.dart';
import 'package:noteswap/features/posts/domain/entities/post_entity.dart';

class CampusFeedScreen extends StatefulWidget {
  const CampusFeedScreen({Key? key}) : super(key: key);

  @override
  State<CampusFeedScreen> createState() => _CampusFeedScreenState();
}

class _CampusFeedScreenState extends State<CampusFeedScreen> {
  late PostController postController;
  final LightModeController lightModeController =
      Get.find<LightModeController>();
  final _searchQuery = ''.obs;

  @override
  void initState() {
    super.initState();
    _initializePostController();
  }

  void _initializePostController() {
    final postRepo = PostRepoImpl();
    postController = PostController(
      createPostUseCase: CreatePostUseCase(repository: postRepo),
      getFeedUseCase: GetFeedUseCase(repository: postRepo),
      getFeedByTagUseCase: GetFeedByTagUseCase(repository: postRepo),
      getTopVotedPostsUseCase: GetTopVotedPostsUseCase(repository: postRepo),
      upvotePostUseCase: UpvotePostUseCase(repository: postRepo),
      downvotePostUseCase: DownvotePostUseCase(repository: postRepo),
      addCommentUseCase: AddCommentUseCase(repository: postRepo),
      getCommentsUseCase: GetCommentsUseCase(repository: postRepo),
      deleteCommentUseCase: DeleteCommentUseCase(repository: postRepo),
      toggleCommentLikeUseCase: ToggleCommentLikeUseCase(repository: postRepo),
      getUserVotesUseCase: GetUserVotesUseCase(repository: postRepo),
      deletePostUseCase: DeletePostUseCase(repository: postRepo),
      getUserLikedCommentsUseCase:
          GetUserLikedCommentsUseCase(repository: postRepo),
    );

    // Load feed when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthCubit>().state;
      if (authState is Authenticated) {
        postController.loadFeed(authState.user);
      }
    });
  }

  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        if (authState is! Authenticated) {
          return Scaffold(
            body: Center(
              child: Text(
                'Please login to view the feed',
                style: TextStyle(
                  color: lightModeController.isLightMode.value
                      ? Colors.black
                      : Colors.white,
                ),
              ),
            ),
          );
        }

        final currentUser = authState.user;
        final isLightMode = lightModeController.isLightMode.value;

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
            leading: IconButton(
              icon: Icon(Icons.menu, color: textColor),
              onPressed: () {},
            ),
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
              Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.notifications_none, color: textColor),
                    onPressed: () {},
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: Obx(() {
            if (postController.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF6139ED)),
              );
            }

            if (postController.errorMessage.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      postController.errorMessage.value,
                      style: TextStyle(color: textColor),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => postController.loadFeed(currentUser),
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

                // 2. Search Bar and filter icon
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: isLightMode
                                ? Colors.white
                                : const Color(0xFF1E1E1E),
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
                                  onChanged: (val) => _searchQuery.value = val,
                                  decoration: InputDecoration(
                                    hintText: 'Search posts, people, topics...',
                                    hintStyle: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      height: 1.0,
                                      color: isLightMode
                                          ? const Color(0xFF1A1A2E)
                                              .withOpacity(0.5)
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
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {},
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            width: 44,
                            height: 44,
                            child: Image.asset(
                              'assets/posts_screen_assets/filter_icon.png',
                              fit: BoxFit.cover,
                              alignment: Alignment.bottomRight,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (_searchQuery.value.isNotEmpty) ...[
                  // Search Results View
                  _buildHeaderSection('Search Results'),
                  const SizedBox(height: 12),
                  ...(() {
                    final query = _searchQuery.value.toLowerCase();
                    final filteredPosts = postController.posts.where((post) {
                      return post.title.toLowerCase().contains(query) ||
                          post.body.toLowerCase().contains(query) ||
                          post.tag.toLowerCase().contains(query);
                    }).toList();

                    if (filteredPosts.isEmpty) {
                      return [
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
                                "No posts found matching '${_searchQuery.value}'",
                                style: TextStyle(
                                    color: subTextColor, fontSize: 13),
                              ),
                            ),
                          ),
                        )
                      ];
                    }

                    return filteredPosts.map((post) {
                      return PostCard(
                        post: post,
                        onTap: () => Get.to(() => PostDetailPage(
                              post: post,
                              controller: postController,
                              currentUser: currentUser,
                            )),
                        onProfileTap: () => Get.to(() => UserProfileScreen(
                                user: AppUser(
                              uid: post.authorId,
                              email: '',
                              name: post.authorName,
                              collegeId: post.collegeId,
                            ))),
                        onUpvote: () => postController.toggleUpvote(
                          post.id,
                          currentUser.uid,
                          currentUser,
                        ),
                        onDownvote: () => postController.toggleDownvote(
                          post.id,
                          currentUser.uid,
                          currentUser,
                        ),
                        onDelete: post.authorId == currentUser.uid
                            ? () => _confirmDeletePost(post.id, currentUser)
                            : null,
                        isLightMode: isLightMode,
                        isUpvoted: postController.getUserVote(post.id) == 1,
                        isDownvoted: postController.getUserVote(post.id) == -1,
                      );
                    }).toList();
                  }()),
                ] else ...[
                  // 3. Trending Discussions Block
                  _buildHeaderSection(
                    'Trending Discussions',
                    onTap: () => Get.to(() => AllPostsScreen(
                          title: 'Trending Discussions',
                          postsSelector: () => postController.posts.toList()
                            ..sort((a, b) => b.upvotes.compareTo(a.upvotes)),
                          controller: postController,
                          currentUser: currentUser,
                        )),
                  ),
                  const SizedBox(height: 12),
                  if (postController.trendingPosts.isEmpty)
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
                          postController.trendingPosts.take(3).map((post) {
                        return PostCard(
                          post: post,
                          onTap: () => Get.to(() => PostDetailPage(
                                post: post,
                                controller: postController,
                                currentUser: currentUser,
                              )),
                          onProfileTap: () => Get.to(() => UserProfileScreen(
                                  user: AppUser(
                                uid: post.authorId,
                                email: '',
                                name: post.authorName,
                                collegeId: post.collegeId,
                              ))),
                          onUpvote: () => postController.toggleUpvote(
                            post.id,
                            currentUser.uid,
                            currentUser,
                          ),
                          onDownvote: () => postController.toggleDownvote(
                            post.id,
                            currentUser.uid,
                            currentUser,
                          ),
                          onDelete: post.authorId == currentUser.uid
                              ? () => _confirmDeletePost(post.id, currentUser)
                              : null,
                          isLightMode: isLightMode,
                          isUpvoted: postController.getUserVote(post.id) == 1,
                          isDownvoted:
                              postController.getUserVote(post.id) == -1,
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 24),

                  // 4. Announcements Block
                  _buildHeaderSection(
                    'Announcements',
                    onTap: () => Get.to(() => AllAnnouncementsScreen(
                          controller: postController,
                          currentUser: currentUser,
                        )),
                  ),
                  const SizedBox(height: 12),
                  (() {
                    final announcements = postController.posts
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
                          onTap: () => Get.to(() => PostDetailPage(
                                post: post,
                                controller: postController,
                                currentUser: currentUser,
                              )),
                          onProfileTap: () => Get.to(() => UserProfileScreen(
                                  user: AppUser(
                                uid: post.authorId,
                                email: '',
                                name: post.authorName,
                                collegeId: post.collegeId,
                              ))),
                          onUpvote: () => postController.toggleUpvote(
                            post.id,
                            currentUser.uid,
                            currentUser,
                          ),
                          onDownvote: () => postController.toggleDownvote(
                            post.id,
                            currentUser.uid,
                            currentUser,
                          ),
                          onDelete: post.authorId == currentUser.uid
                              ? () => _confirmDeletePost(post.id, currentUser)
                              : null,
                          isLightMode: isLightMode,
                          isUpvoted: postController.getUserVote(post.id) == 1,
                          isDownvoted:
                              postController.getUserVote(post.id) == -1,
                        );
                      }).toList(),
                    );
                  }()),
                  const SizedBox(height: 24),

                  // 5. Latest Posts Block
                  _buildHeaderSection(
                    'Latest Posts',
                    onTap: () => Get.to(() => AllPostsScreen(
                          title: 'Latest Posts',
                          postsSelector: () => postController.posts.toList()
                            ..sort(
                                (a, b) => b.createdAt.compareTo(a.createdAt)),
                          controller: postController,
                          currentUser: currentUser,
                        )),
                  ),
                  const SizedBox(height: 12),
                  if (postController.posts.isEmpty)
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
                      children: postController.posts.take(3).map((post) {
                        return PostCard(
                          post: post,
                          onTap: () => Get.to(() => PostDetailPage(
                                post: post,
                                controller: postController,
                                currentUser: currentUser,
                              )),
                          onProfileTap: () => Get.to(() => UserProfileScreen(
                                  user: AppUser(
                                uid: post.authorId,
                                email: '',
                                name: post.authorName,
                                collegeId: post.collegeId,
                              ))),
                          onUpvote: () => postController.toggleUpvote(
                            post.id,
                            currentUser.uid,
                            currentUser,
                          ),
                          onDownvote: () => postController.toggleDownvote(
                            post.id,
                            currentUser.uid,
                            currentUser,
                          ),
                          onDelete: post.authorId == currentUser.uid
                              ? () => _confirmDeletePost(post.id, currentUser)
                              : null,
                          isLightMode: isLightMode,
                          isUpvoted: postController.getUserVote(post.id) == 1,
                          isDownvoted:
                              postController.getUserVote(post.id) == -1,
                        );
                      }).toList(),
                    ),
                ],
                const SizedBox(height: 100), // extra padding for nav bar
              ],
            );
          }),
          // Premium bottom navigation bar
          bottomNavigationBar: Container(
            margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(30),
              boxShadow: isLightMode
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : [],
              border: Border.all(
                color: isLightMode ? Colors.grey[100]! : Colors.grey[850]!,
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Get.offAll(() => const MainPage());
                    Get.find<MainPageController>().changeIndex(0);
                  },
                  child: _buildNavItem(
                      Icons.home, 'Home', true, brandColor, subTextColor),
                ),
                GestureDetector(
                  onTap: () {
                    Get.offAll(() => const MainPage());
                    Get.find<MainPageController>().changeIndex(1);
                  },
                  child: _buildNavItem(Icons.people_outline, 'Communities',
                      false, brandColor, subTextColor),
                ),
                // Floating center button
                GestureDetector(
                  onTap: () => Get.to(() => CreatePostPage(
                        controller: postController,
                        currentUser: currentUser,
                      )),
                  child: Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: brandColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: brandColor.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 28),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Get.offAll(() => const MainPage());
                    Get.find<MainPageController>().changeIndex(2);
                  },
                  child: _buildNavItem(Icons.chat_bubble_outline, 'Messages',
                      false, brandColor, subTextColor),
                ),
                GestureDetector(
                  onTap: () {
                    Get.offAll(() => const MainPage());
                    Get.find<MainPageController>().changeIndex(3);
                  },
                  child: _buildNavItem(Icons.person_outline, 'Profile', false,
                      brandColor, subTextColor),
                ),
              ],
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
        postController.trendingPosts.indexWhere((p) => p.id == initialPost.id);
    final post =
        postIndex != -1 ? postController.trendingPosts[postIndex] : initialPost;
    final userVote = postController.getUserVote(post.id);
    final timeStr = formatTimeAgo(post.createdAt);
    final groupName = 'r/${post.tag.replaceAll(" ", "")}';

    return GestureDetector(
      onTap: () => Get.to(() => PostDetailPage(
            post: post,
            controller: postController,
            currentUser: currentUser,
          )),
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
                  onTap: () => postController.toggleUpvote(
                      post.id, currentUser.uid, currentUser),
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
                  onTap: () => postController.toggleDownvote(
                      post.id, currentUser.uid, currentUser),
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
              onPressed: () async {
                Navigator.pop(context);
                await postController.removePost(postId, currentUser);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
