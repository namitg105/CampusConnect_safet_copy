import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:noteswap/features/admin_events/presentation/screens/AdminEvent.dart';
import 'package:noteswap/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:noteswap/features/auth/presentation/cubits/auth_states.dart';
import 'package:noteswap/features/posts/data/profile_repo_impl.dart';
import 'package:noteswap/features/posts/domain/usecases/get_profile_usecase.dart';
import 'package:noteswap/features/posts/presentation/pages/campus_feed_screen.dart';
import 'package:noteswap/features/posts/domain/usecases/get_feed_usecase.dart';
import 'package:noteswap/features/posts/data/post_repo_impl.dart';
import 'package:noteswap/features/posts/domain/entities/post_entity.dart';
import 'package:noteswap/utils/time_formatter.dart';
import 'package:noteswap/features/auth/domain/entities/app_user.dart';
import 'package:noteswap/features/group_chat/presentation/pages/groups_page.dart';
import 'package:noteswap/features/events/notifications/notifications_screen.dart';
import 'package:noteswap/ViewModels/NotificationController.dart';
import 'package:noteswap/features/posts/presentation/pages/post_detail_page.dart';
import 'package:noteswap/features/posts/presentation/pages/all_announcements_screen.dart';
import 'package:noteswap/features/posts/presentation/controllers/post_controller.dart';
import 'package:noteswap/features/posts/domain/usecases/create_post_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/get_feed_by_tag_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/get_top_voted_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/upvote_post_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/downvote_post_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/add_comment_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/get_comments_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/delete_comment_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/toggle_comment_like_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/get_user_votes_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/delete_post_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/get_user_liked_comments_usecase.dart';

class DashboardPageOne extends StatefulWidget {
  const DashboardPageOne({super.key});

  @override
  State<DashboardPageOne> createState() => _DashboardPageOneState();
}

class _DashboardPageOneState extends State<DashboardPageOne> {
  late final GetProfileUseCase profileUseCase;
  late final GetFeedUseCase feedUseCase;
  Map<String, dynamic>? profileData;
  List<PostEntity> newestDiscussions = [];
  List<PostEntity> announcementPosts = [];
  bool isLoading = true;
  String? _loadedUid;
  bool _isRefreshing = false;

  PostController _createPostController() {
    final postRepo = PostRepoImpl();
    return PostController(
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
  }

  Future<void> _handleRefresh() async {
    final authState = context.read<AuthCubit>().state;
    if (authState is Authenticated) {
      setState(() {
        _isRefreshing = true;
      });
      await _loadProfileForUser(authState.user, forceRefresh: true);
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  // Motivation Quote State
  int _currentQuoteIndex = 0;
  final List<Map<String, String>> _quotes = const [
    {
      'quote': 'The expert in anything was once a beginner.',
      'author': 'Helen Hayes'
    },
    {
      'quote': 'Push yourself, because no one else is going to do it for you.',
      'author': 'Unknown'
    },
    {
      'quote': 'Small daily improvements over time lead to stunning results.',
      'author': 'Robin Sharma'
    },
    {
      'quote': 'Your future is created by what you do today, not tomorrow.',
      'author': 'Robert Kiyosaki'
    },
    {
      'quote': 'Focus on being productive instead of busy.',
      'author': 'Tim Ferriss'
    },
  ];

  @override
  void initState() {
    super.initState();
    profileUseCase = GetProfileUseCase(repository: ProfileRepoImpl());
    feedUseCase = GetFeedUseCase(repository: PostRepoImpl());

    // Check if user is already authenticated at initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthCubit>().state;
      if (authState is Authenticated) {
        _loadProfileForUser(authState.user);
      } else {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  Future<void> _loadProfileForUser(AppUser user,
      {bool forceRefresh = false}) async {
    if (_loadedUid == user.uid && !isLoading && !forceRefresh) return;

    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    final data = await profileUseCase.call(user.uid);
    final collegeId = data?['collegeId'] as String? ?? user.collegeId;

    List<PostEntity> feed = [];
    List<PostEntity> announcements = [];
    if (collegeId.isNotEmpty) {
      try {
        feed = await feedUseCase.call(collegeId);
        announcements =
            feed.where((p) => p.tag.toLowerCase() == 'announcement').toList();
        print("[DashboardOne] Resolved collegeId: '$collegeId'");
        print(
            "[DashboardOne] Fetched feed posts count: ${feed.length}, announcements count: ${announcements.length}");
      } catch (e) {
        print("[DashboardOne] Error fetching feed: $e");
      }
    } else {
      print("[DashboardOne] Warning: collegeId is empty.");
    }

    if (mounted) {
      setState(() {
        _loadedUid = user.uid;
        profileData = data;
        newestDiscussions = feed.take(3).toList();
        announcementPosts = announcements;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    final backgroundColor =
        isLightMode ? const Color(0xFFF9F9FB) : const Color(0xFF121212);
    final cardColor = isLightMode ? Colors.white : const Color(0xFF1E1E1E);
    final textColor = isLightMode ? Colors.black87 : Colors.white;
    final subTextColor = isLightMode ? Colors.grey[600] : Colors.grey[400];
    final brandColor = const Color(0xFF6139ED);

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          _loadProfileForUser(state.user);
        }
      },
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, authState) {
          String displayName = 'Naresh';
          if (authState is Authenticated) {
            final user = authState.user;
            displayName = profileData?['name'] ??
                (user.name.isNotEmpty
                    ? user.name
                    : (user.email.contains('@')
                        ? user.email.split('@').first
                        : user.email));
          }

          return Scaffold(
            backgroundColor: backgroundColor,
            body: SafeArea(
              child: Column(
                children: [
                  // Custom App Bar
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _isRefreshing
                            ? const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFF6139ED)),
                                  ),
                                ),
                              )
                            : IconButton(
                                onPressed: _handleRefresh,
                                icon: Icon(Icons.refresh, color: textColor),
                              ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: brandColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.school,
                                  color: brandColor, size: 24),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'uniConnect',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: brandColor,
                              ),
                            ),
                          ],
                        ),
                        Builder(
                          builder: (context) {
                            final notifCtrl = Get.put(NotificationController());
                            return Obx(
                              () => Stack(
                                alignment: Alignment.center,
                                children: [
                                  IconButton(
                                    onPressed: () => Get.to(
                                        () => const NotificationsScreen()),
                                    icon: Icon(Icons.notifications_none,
                                        color: textColor),
                                  ),
                                  if (notifCtrl.unreadCount.value > 0)
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
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF6139ED),
                            ),
                          )
                        : ListView(
                            padding: const EdgeInsets.all(16),
                            children: [
                              // Greeting
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        textColor, // Base color for standard text
                                  ),
                                  children: [
                                    const TextSpan(
                                        text: 'Hey, ',
                                        style: TextStyle(fontSize: 22)),
                                    WidgetSpan(
                                      child: ShaderMask(
                                        shaderCallback: (bounds) =>
                                            const LinearGradient(
                                          colors: [
                                            Color(0xFF6366F1),
                                            Color(0xFFA855F7)
                                          ], // Indigo to Purple
                                        ).createShader(bounds),
                                        child: Text(
                                          displayName,
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors
                                                .white, // Required for ShaderMask
                                          ),
                                        ),
                                      ),
                                    ),
                                    const TextSpan(text: ' '),
                                    const TextSpan(text: '👋'),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Ready to connect and explore today?',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: subTextColor,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Motivational Quotes Card (Replaces Search Bar)
                              _buildQuoteCard(cardColor, textColor,
                                  subTextColor, brandColor),
                              const SizedBox(height: 24),

                              // Quick Access Section
                              _buildHeader('Quick Access', showViewAll: false),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildQuickAccessItem(
                                      Icons.groups,
                                      'Group Chat',
                                      brandColor,
                                      cardColor,
                                      textColor,
                                      onTap: () {
                                        if (authState is Authenticated) {
                                          Get.to(() => GroupsDisplayPage());
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildQuickAccessItem(
                                      Icons.chat_bubble,
                                      'Feed Discussions',
                                      brandColor,
                                      cardColor,
                                      textColor,
                                      onTap: () => Get.to(
                                          () => const CampusFeedScreen()),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildQuickAccessItem(
                                      Icons.calendar_month,
                                      'Events',
                                      brandColor,
                                      cardColor,
                                      textColor,
                                      onTap: () => Get.to(
                                          () => AllCommunityEventsPage()),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Announcements Section
                              _buildHeader(
                                'Announcements',
                                onViewAll: () {
                                  if (authState is Authenticated) {
                                    final postController =
                                        _createPostController();
                                    Get.to(() => AllAnnouncementsScreen(
                                          controller: postController,
                                          currentUser: authState.user,
                                        ));
                                  }
                                },
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 140,
                                child: announcementPosts.isNotEmpty
                                    ? ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        physics: const BouncingScrollPhysics(),
                                        itemCount: announcementPosts.length,
                                        itemBuilder: (context, index) {
                                          final post = announcementPosts[index];
                                          final colorPalettes = [
                                            {
                                              'iconColor':
                                                  const Color(0xFF6139ED),
                                              'bgColor':
                                                  const Color(0xFFECE7FF),
                                            },
                                            {
                                              'iconColor':
                                                  const Color(0xFF8B5CF6),
                                              'bgColor':
                                                  const Color(0xFFF3E8FF),
                                            },
                                            {
                                              'iconColor':
                                                  const Color(0xFF4F46E5),
                                              'bgColor':
                                                  const Color(0xFFE0E7FF),
                                            },
                                          ];
                                          final palette = colorPalettes[
                                              index % colorPalettes.length];
                                          final authorName = post.authorName
                                                  .contains('@')
                                              ? post.authorName.split('@').first
                                              : post.authorName;

                                          return _buildTrendingCard(
                                            post.title,
                                            '$authorName • ${formatTimeAgo(post.createdAt)}',
                                            Icons.campaign_rounded,
                                            palette['iconColor']!,
                                            palette['bgColor']!,
                                            onTap: () {
                                              if (authState is Authenticated) {
                                                final postController =
                                                    _createPostController();
                                                Get.to(() => PostDetailPage(
                                                      post: post,
                                                      controller:
                                                          postController,
                                                      currentUser:
                                                          authState.user,
                                                    ));
                                              }
                                            },
                                          );
                                        },
                                      )
                                    : ListView(
                                        scrollDirection: Axis.horizontal,
                                        physics: const BouncingScrollPhysics(),
                                        children: [
                                          _buildTrendingCard(
                                            'No Announcements',
                                            'Stay tuned for updates',
                                            Icons.campaign_outlined,
                                            const Color(0xFF6139ED),
                                            const Color(0xFFECE7FF),
                                          ),
                                        ],
                                      ),
                              ),
                              const SizedBox(height: 24),

                              // Recent Discussions Section
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Recent Discussions',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: textColor,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => Get.to(
                                              () => const CampusFeedScreen()),
                                          child: Text(
                                            'View all',
                                            style: TextStyle(
                                              color: brandColor,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 24),
                                    if (newestDiscussions.isEmpty)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 24.0),
                                        child: Center(
                                          child: Text(
                                            'No discussions yet',
                                            style: TextStyle(
                                                color: subTextColor,
                                                fontSize: 11),
                                          ),
                                        ),
                                      )
                                    else ...[
                                      for (int i = 0;
                                          i < newestDiscussions.length;
                                          i++) ...[
                                        if (i > 0) const Divider(height: 16),
                                        _buildDiscussionItem(
                                          newestDiscussions[i],
                                          brandColor,
                                          textColor,
                                          subTextColor,
                                          isLightMode,
                                        ),
                                      ]
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: 100), // bottom nav space
                            ],
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuoteCard(
      Color cardColor, Color textColor, Color? subTextColor, Color brandColor) {
    final currentQuote = _quotes[_currentQuoteIndex];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // Vibrant gradient background
        gradient: const LinearGradient(
          colors: [Color(0xFF6139ED), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6139ED).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Colors.amberAccent,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'DAILY MOTIVATION',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              // Next Quote Button
              InkWell(
                onTap: () {
                  setState(() {
                    _currentQuoteIndex =
                        (_currentQuoteIndex + 1) % _quotes.length;
                  });
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.25),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.refresh_rounded,
                          size: 12, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'Next',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Quote Content with Decorative Large Quote Mark
          Stack(
            children: [
              Positioned(
                right: 0,
                bottom: -10,
                child: Text(
                  '”',
                  style: TextStyle(
                    fontSize: 70,
                    fontFamily: 'Serif',
                    color: Colors.white.withOpacity(0.15),
                    height: 1,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Text(
                  '"${currentQuote['quote']}"',
                  style: const TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Author
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '— ${currentQuote['author']}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white.withOpacity(0.9),
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String title,
      {bool showViewAll = true, VoidCallback? onViewAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (showViewAll)
          GestureDetector(
            onTap: onViewAll,
            child: const Text(
              'View all',
              style: TextStyle(
                color: Color(0xFF6139ED),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildQuickAccessItem(IconData icon, String label, Color brandColor,
      Color cardColor, Color textColor,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 96,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: brandColor, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingCard(String title, String members, IconData icon,
      Color iconColor, Color bgColor,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 24),
            const Spacer(),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: iconColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              members,
              style: TextStyle(
                fontSize: 9,
                color: iconColor.withOpacity(0.8),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              height: 12,
              child: CustomPaint(
                painter: WavyLinePainter(iconColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscussionItem(PostEntity post, Color brandColor,
      Color textColor, Color? subTextColor, bool isLightMode) {
    final formattedAuthor = post.authorName.contains('@')
        ? post.authorName.split('@').first
        : post.authorName;

    return GestureDetector(
      onTap: () {
        Get.to(() => PostDetailPage(
              post: post,
              controller: Get.find<PostController>(),
            ));
      },
      child: Container(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    post.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      color: textColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: brandColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    post.commentCount.toString(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: brandColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '$formattedAuthor • ${formatTimeAgo(post.createdAt)}',
              style: TextStyle(
                fontSize: 9,
                color: subTextColor,
              ),
            ),
            if (post.imageUrl != null && post.imageUrl!.isNotEmpty) ...[
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  post.imageUrl!,
                  height: 80,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 80,
                    color: isLightMode
                        ? const Color(0xFFF3F4F6)
                        : const Color(0xFF2D2D2D),
                    child: const Center(
                      child: Icon(Icons.image_not_supported_outlined,
                          color: Colors.grey, size: 24),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
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
}

class WavyLinePainter extends CustomPainter {
  final Color color;
  WavyLinePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path();
    path.moveTo(0, size.height / 2);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.1,
      size.width * 0.5,
      size.height / 2,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.9,
      size.width,
      size.height / 2,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
