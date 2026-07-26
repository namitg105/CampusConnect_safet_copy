import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:noteswap/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:noteswap/features/auth/presentation/cubits/auth_states.dart';
import 'package:noteswap/features/posts/data/profile_repo_impl.dart';
import 'package:noteswap/features/posts/domain/usecases/get_profile_usecase.dart';
import 'package:noteswap/features/posts/presentation/pages/campus_feed_screen.dart';
import 'package:noteswap/features/private_chat/page_controller.dart';
import 'package:noteswap/features/profile/presentation/pages/profile_settings_page.dart';
import 'package:noteswap/features/posts/domain/usecases/get_feed_usecase.dart';
import 'package:noteswap/features/posts/data/post_repo_impl.dart';
import 'package:noteswap/features/posts/domain/entities/post_entity.dart';
import 'package:noteswap/utils/time_formatter.dart';
import 'package:noteswap/features/auth/domain/entities/app_user.dart';

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
  bool isLoading = true;
  String? _loadedUid;

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

  Future<void> _loadProfileForUser(AppUser user) async {
    if (_loadedUid == user.uid && !isLoading) return;

    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    final data = await profileUseCase.call(user.uid);
    final collegeId = data?['collegeId'] as String? ?? user.collegeId;

    List<PostEntity> feed = [];
    if (collegeId.isNotEmpty) {
      try {
        feed = await feedUseCase.call(collegeId);
        print("[DashboardOne] Resolved collegeId: '$collegeId'");
        print("[DashboardOne] Fetched feed posts count: ${feed.length}");
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
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.menu, color: textColor),
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
                        IconButton(
                          onPressed: () {},
                          icon:
                              Icon(Icons.notifications_none, color: textColor),
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
                              Text(
                                'Hey $displayName! 👋',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
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

                              // Search Bar
                              Container(
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText:
                                        'Search for communities, people, discussions...',
                                    hintStyle: TextStyle(
                                        color: subTextColor, fontSize: 13),
                                    prefixIcon: Icon(Icons.search,
                                        color: subTextColor, size: 20),
                                    suffixIcon: Icon(Icons.filter_list,
                                        color: brandColor, size: 20),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Quick Access Section
                              _buildHeader('Quick Access'),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 110,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  children: [
                                    _buildQuickAccessItem(
                                        Icons.groups,
                                        'My communities',
                                        brandColor,
                                        cardColor,
                                        textColor),
                                    _buildQuickAccessItem(
                                      Icons.chat_bubble,
                                      'Discussions',
                                      brandColor,
                                      cardColor,
                                      textColor,
                                      onTap: () => Get.to(
                                          () => const CampusFeedScreen()),
                                    ),
                                    _buildQuickAccessItem(
                                        Icons.calendar_month,
                                        'Events',
                                        brandColor,
                                        cardColor,
                                        textColor),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Trending Communities
                              _buildHeader('Trending Communities'),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 140,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  children: [
                                    _buildTrendingCard(
                                      'Coding Club',
                                      '542 members',
                                      Icons.code,
                                      const Color(0xFF6139ED),
                                      const Color(0xFFECE7FF),
                                    ),
                                    _buildTrendingCard(
                                      'Basketball Team',
                                      '320 members',
                                      Icons.sports_basketball,
                                      const Color(0xFF00BFA5),
                                      const Color(0xFFE0F2F1),
                                    ),
                                    _buildTrendingCard(
                                      'Photography Club',
                                      '256 members',
                                      Icons.camera_alt,
                                      const Color(0xFFFF6D00),
                                      const Color(0xFFFBE9E7),
                                    ),
                                    _buildTrendingCard(
                                      'Music club',
                                      '460 members',
                                      Icons.headphones,
                                      const Color(0xFF2979FF),
                                      const Color(0xFFE3F2FD),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Recent Discussions & Announcements block
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Recent Discussions Card
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: cardColor,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.03),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  'Recent Discussions',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                    color: textColor,
                                                  ),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () => Get.to(() =>
                                                    const CampusFeedScreen()),
                                                child: Text(
                                                  'View all',
                                                  style: TextStyle(
                                                    color: brandColor,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Divider(height: 16),
                                          if (newestDiscussions.isEmpty)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 16.0),
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
                                              if (i > 0)
                                                const Divider(height: 16),
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
                                  ),
                                  const SizedBox(width: 12),
                                  // Announcements Card
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: cardColor,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.03),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Announcements',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                  color: textColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Divider(height: 16),
                                          _buildAnnouncementItem(
                                            'CAT-I Exam Schedule Released',
                                            'Check your vtop portal',
                                            textColor,
                                            subTextColor,
                                          ),
                                          const Divider(height: 16),
                                          _buildAnnouncementItem(
                                            'Annual Tech Fest 2025 Registrations Open!',
                                            'Don\'t miss out!',
                                            textColor,
                                            subTextColor,
                                          ),
                                          const Divider(height: 16),
                                          _buildAnnouncementItem(
                                            'New Scholarships Available',
                                            'Apply before the deadline',
                                            textColor,
                                            subTextColor,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 80), // bottom nav space
                            ],
                          ),
                  ),
                ],
              ),
            ),
            // Premium floating navigation bar layout
            bottomNavigationBar: Container(
              margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildNavItem(
                      Icons.home, 'Home', true, brandColor, subTextColor),
                  _buildNavItem(Icons.people_outline, 'Communities', false,
                      brandColor, subTextColor),
                  // Floating center button
                  Container(
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
                  GestureDetector(
                    onTap: () {
                      final authState = context.read<AuthCubit>().state;
                      if (authState is Authenticated) {
                        Get.to(
                          () => const PrivateChatPageController());
                      }
                    },
                    child: _buildNavItem(Icons.chat_bubble_outline, 'Messages',
                        false, brandColor, subTextColor),
                  ),
                  GestureDetector(
                    onTap: () => Get.to(() => const ProfileSettingsPage()),
                    child: _buildNavItem(Icons.person_outline, 'Profile', false,
                        brandColor, subTextColor),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(String title) {
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
        const Text(
          'View all',
          style: TextStyle(
            color: Color(0xFF6139ED),
            fontWeight: FontWeight.w600,
            fontSize: 13,
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
        width: 90,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
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
      Color iconColor, Color bgColor) {
    return Container(
      width: 110,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 26),
          const Spacer(),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            members,
            style: TextStyle(
              fontSize: 9,
              color: iconColor.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 12,
            child: CustomPaint(
              painter: WavyLinePainter(iconColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscussionItem(PostEntity post, Color brandColor,
      Color textColor, Color? subTextColor, bool isLightMode) {
    final formattedAuthor = post.authorName.contains('@')
        ? post.authorName.split('@').first
        : post.authorName;

    return Column(
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
            child: Image.asset(
              'assets/Screenshot 2026-07-24 111253.png',
              height: 80,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAnnouncementItem(
      String title, String subtitle, Color textColor, Color? subTextColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 11,
            color: textColor,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 9,
            color: subTextColor,
          ),
        ),
      ],
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
