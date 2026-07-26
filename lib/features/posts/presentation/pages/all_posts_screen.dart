import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noteswap/features/auth/domain/entities/app_user.dart';
import 'package:noteswap/features/posts/domain/entities/post_entity.dart';
import 'package:noteswap/features/posts/presentation/controllers/post_controller.dart';
import 'package:noteswap/features/posts/presentation/widgets/post_card.dart';
import 'package:noteswap/features/posts/presentation/pages/post_detail_page.dart';
import 'package:noteswap/features/posts/presentation/pages/user_profile_screen.dart';
import 'package:noteswap/ViewModels/DarkModeViewModels.dart';

class AllPostsScreen extends StatelessWidget {
  final String title;
  final List<PostEntity> Function() postsSelector;
  final PostController controller;
  final AppUser currentUser;

  const AllPostsScreen({
    super.key,
    required this.title,
    required this.postsSelector,
    required this.controller,
    required this.currentUser,
  });

  void _confirmDeletePost(BuildContext context, String postId) {
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
              onPressed: () async {
                Navigator.pop(context);
                await controller.removePost(postId, currentUser);
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
    final LightModeController lightModeController =
        Get.find<LightModeController>();

    return Obx(() {
      final isLightMode = lightModeController.isLightMode.value;

      final backgroundColor =
          isLightMode ? const Color(0xFFF4F1FC) : const Color(0xFF121214);
      final textColor = isLightMode ? const Color(0xFF1A1A1E) : Colors.white;
      final subTextColor =
          isLightMode ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF);

      // Dynamically select and sort the posts to display
      final displayedPosts = postsSelector();

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
                    onTap: () => Get.to(() => PostDetailPage(
                          post: post,
                          controller: controller,
                          currentUser: currentUser,
                        )),
                    onProfileTap: () => Get.to(() => UserProfileScreen(
                            user: AppUser(
                          uid: post.authorId,
                          email: '',
                          name: post.authorName,
                          collegeId: post.collegeId,
                        ))),
                    onUpvote: () => controller.toggleUpvote(
                      post.id,
                      currentUser.uid,
                      currentUser,
                    ),
                    onDownvote: () => controller.toggleDownvote(
                      post.id,
                      currentUser.uid,
                      currentUser,
                    ),
                    onDelete: post.authorId == currentUser.uid
                        ? () => _confirmDeletePost(context, post.id)
                        : null,
                    isUpvoted: controller.getUserVote(post.id) == 1,
                    isDownvoted: controller.getUserVote(post.id) == -1,
                    isLightMode: isLightMode,
                  );
                },
              ),
      );
    });
  }
}
