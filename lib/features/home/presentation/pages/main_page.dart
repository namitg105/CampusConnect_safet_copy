import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:noteswap/Views/FeedScreen.dart';
import 'package:noteswap/features/community/presentation/pages/create_group_page.dart';
import 'package:noteswap/features/dashboard/presentation/pages/dashboard_page_one.dart';
import 'package:noteswap/features/notes_swap/FeedScreen.dart';
import 'package:noteswap/features/private_chat/page_controller.dart';
import 'package:noteswap/features/profile/presentation/pages/profile_settings_page.dart';
import 'package:noteswap/features/posts/presentation/pages/create_post_page.dart';
import 'package:noteswap/features/posts/presentation/controllers/post_controller.dart';
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
import 'package:noteswap/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:noteswap/features/auth/presentation/cubits/auth_states.dart';

import '../../../../core/di/injection.dart';
import '../../../community/presentation/cubits/group_cubit.dart';
import '../../../community/presentation/pages/groups_page.dart';

class MainPageController extends GetxController {
  var currentIndex = 0.obs;
  var privateChatSelectedTab = 0.obs;

  @override
  void onInit() {
    super.onInit();
    currentIndex.value = 0;
  }

  void changeIndex(int index) {
    currentIndex.value = index;
  }
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MainPageController());
    const Color brandPrimary = Color(0xFF6366F1);
    const Color textDark = Color(0xFF0F172A);
    const Color textMuted = Color(0xFF64748B);

    void handleCenterButtonTap() {
      final index = controller.currentIndex.value;
      if (index == 0) {
        final authState = context.read<AuthCubit>().state;
        if (authState is Authenticated) {
          final currentUser = authState.user;
          final postRepo = PostRepoImpl();
          final postController = PostController(
            createPostUseCase: CreatePostUseCase(repository: postRepo),
            getFeedUseCase: GetFeedUseCase(repository: postRepo),
            getFeedByTagUseCase: GetFeedByTagUseCase(repository: postRepo),
            getTopVotedPostsUseCase:
                GetTopVotedPostsUseCase(repository: postRepo),
            upvotePostUseCase: UpvotePostUseCase(repository: postRepo),
            downvotePostUseCase: DownvotePostUseCase(repository: postRepo),
            addCommentUseCase: AddCommentUseCase(repository: postRepo),
            getCommentsUseCase: GetCommentsUseCase(repository: postRepo),
            deleteCommentUseCase: DeleteCommentUseCase(repository: postRepo),
            toggleCommentLikeUseCase:
                ToggleCommentLikeUseCase(repository: postRepo),
            getUserVotesUseCase: GetUserVotesUseCase(repository: postRepo),
            deletePostUseCase: DeletePostUseCase(repository: postRepo),
            getUserLikedCommentsUseCase:
                GetUserLikedCommentsUseCase(repository: postRepo),
          );
          Get.to(() => CreatePostPage(
                controller: postController,
                currentUser: currentUser,
              ));
        }
      } else if (index == 1) {
        Get.to(() => const CreateGroupPage(collegeId: ""));
      } else if (index == 3) {
        controller.privateChatSelectedTab.value = 3;
      } else if (index == 2) {
        // Handle action for NoteSwap center tab if needed
      }
    }

    return BlocProvider<GroupCubit>(
      create: (_) => sl<GroupCubit>(),
      child: Obx(
        () => Scaffold(
          extendBody: true,
          body: IndexedStack(
            index: controller.currentIndex.value,
            children: [
              const DashboardPageOne(), // Index 0: Home
              const GroupsPage(), // Index 1: Community
              NoteSwapFeedScreen(),
              const PrivateChatPageController(), // Index 3: Messages
              const ProfileSettingsPage(), // Index 4: Profile
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: SizedBox(
                height: 80, // Expanded height to accommodate elevated button
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomCenter,
                  children: [
                    // Main navigation bar pill container
                    Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F1FE),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: textDark.withOpacity(0.06),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Left Section: Home & Community
                          Expanded(
                            flex: 2,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _NavBarIcon(
                                  assetPath: 'assets/community/home_nav.png',
                                  label: 'Home',
                                  isSelected:
                                      controller.currentIndex.value == 0,
                                  activeColor: brandPrimary,
                                  inactiveColor: textMuted,
                                  onTap: () => controller.changeIndex(0),
                                ),
                                _NavBarIcon(
                                  assetPath: 'assets/community/comm_nav.png',
                                  label: 'Community',
                                  isSelected:
                                      controller.currentIndex.value == 1,
                                  activeColor: brandPrimary,
                                  inactiveColor: textMuted,
                                  onTap: () => controller.changeIndex(1),
                                ),
                              ],
                            ),
                          ),

                          // Center Section: NoteSwap Tab
                          Expanded(
                            flex: 1,
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _NavBarIcon(
                                  icon: Icons.swap_horiz_rounded,
                                  label: 'NoteSwap',
                                  isSelected:
                                      controller.currentIndex.value == 2,
                                  activeColor: brandPrimary,
                                  inactiveColor: textMuted,
                                  onTap: () => controller.changeIndex(2),
                                ),
                              ),
                            ),
                          ),

                          // Right Section: Messages & Profile
                          Expanded(
                            flex: 2,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _NavBarIcon(
                                  assetPath: 'assets/community/msg_nav.png',
                                  label: 'Messages',
                                  isSelected:
                                      controller.currentIndex.value == 3,
                                  activeColor: brandPrimary,
                                  inactiveColor: textMuted,
                                  onTap: () => controller.changeIndex(3),
                                ),
                                _NavBarIcon(
                                  assetPath: 'assets/community/prof_nav.png',
                                  label: 'Profile',
                                  isSelected:
                                      controller.currentIndex.value == 4,
                                  activeColor: brandPrimary,
                                  inactiveColor: textMuted,
                                  onTap: () => controller.changeIndex(4),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Floating Action Button pushed higher up (Only shown on Index 0 / Dashboard 1)
                    if (controller.currentIndex.value == 0)
                      Positioned(
                        top: -35,
                        child: _CreateButton(
                          color: brandPrimary,
                          onTap: handleCenterButtonTap,
                          bottomPadding: 0,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarIcon extends StatelessWidget {
  final IconData? icon;
  final String? assetPath;
  final String label;
  final bool isSelected;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  const _NavBarIcon({
    this.icon,
    this.assetPath,
    required this.label,
    required this.isSelected,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  }) : assert(
          icon != null || assetPath != null,
          'Either icon or assetPath must be provided',
        );

  @override
  Widget build(BuildContext context) {
    final currentColor = isSelected ? activeColor : inactiveColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withOpacity(0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (assetPath != null)
              Image.asset(
                assetPath!,
                width: 18,
                height: 18,
                color: currentColor,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.groups_rounded,
                  size: 18,
                  color: currentColor,
                ),
              )
            else
              Icon(
                icon,
                size: 18,
                color: currentColor,
              ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 8.5,
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

class _CreateButton extends StatelessWidget {
  final Color color;
  final VoidCallback onTap;
  final double bottomPadding;

  const _CreateButton({
    required this.color,
    required this.onTap,
    this.bottomPadding = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
        ),
      ),
    );
  }
}
