import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noteswap/features/auth/domain/entities/app_user.dart';
import 'package:noteswap/features/posts/presentation/controllers/post_controller.dart';
import 'package:noteswap/features/posts/presentation/pages/post_detail_page.dart';
import 'package:noteswap/ViewModels/DarkModeViewModels.dart';
import 'package:noteswap/utils/time_formatter.dart';
import 'package:google_fonts/google_fonts.dart';

class AllAnnouncementsScreen extends StatelessWidget {
  final PostController controller;
  final AppUser currentUser;

  const AllAnnouncementsScreen({
    super.key,
    required this.controller,
    required this.currentUser,
  });

  // Dynamic asset configuration cycles
  static const List<Color> bgColors = [
    Color(0xFFECE7FF), // light purple
    Color(0xFFFEF9C3), // light yellow
    Color(0xFFE0F2FE), // light blue
    Color(0xFFDCFCE7), // light green
  ];

  static const List<Color> themeColors = [
    Color(0xFF6139ED),
    Color(0xFFD97706),
    Color(0xFF0369A1),
    Color(0xFF15803D),
  ];

  static const List<IconData> icons = [
    Icons.campaign_outlined,
    Icons.announcement_outlined,
    Icons.notifications_none,
    Icons.info_outline,
  ];

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
      final cardColor = isLightMode ? Colors.white : const Color(0xFF1E1E22);

      // Filter posts that have the tag "Announcement"
      final announcementPosts = controller.posts
          .where((p) => p.tag.toLowerCase() == 'announcement')
          .toList();

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
            'Announcements',
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: announcementPosts.isEmpty
            ? Center(
                child: Text(
                  'No announcements yet',
                  style: TextStyle(color: subTextColor, fontSize: 14),
                ),
              )
            : ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: announcementPosts.length,
                itemBuilder: (context, index) {
                  final post = announcementPosts[index];
                  final bgColor = bgColors[index % bgColors.length];
                  final themeColor = themeColors[index % themeColors.length];
                  final icon = icons[index % icons.length];
                  final date = formatTimeAgo(post.createdAt);

                  return GestureDetector(
                    onTap: () => Get.to(() => PostDetailPage(
                          post: post,
                          controller: controller,
                          currentUser: currentUser,
                        )),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
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
                          color: isLightMode
                              ? Colors.grey[100]!
                              : Colors.grey[850]!,
                          width: 0.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  icon,
                                  color: themeColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      post.title,
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                        height: 1.45,
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      date,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: themeColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            post.body,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              height: 1.5,
                              color: subTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      );
    });
  }
}
