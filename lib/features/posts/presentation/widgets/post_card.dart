import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:noteswap/features/posts/domain/entities/post_entity.dart';
import 'package:noteswap/utils/time_formatter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_fonts/google_fonts.dart';

// SVG Assets matching Figma specifications perfectly
const String upvoteSvg = '''
<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <line x1="12" y1="19" x2="12" y2="5"></line>
  <polyline points="5 12 12 5 19 12"></polyline>
</svg>
''';

const String downvoteSvg = '''
<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <line x1="12" y1="5" x2="12" y2="19"></line>
  <polyline points="19 12 12 19 5 12"></polyline>
</svg>
''';

const String commentSvg = '''
<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"></path>
</svg>
''';

const String shareSvg = '''
<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <circle cx="18" cy="5" r="3"></circle>
  <circle cx="6" cy="12" r="3"></circle>
  <circle cx="18" cy="19" r="3"></circle>
  <line x1="8.59" y1="13.51" x2="15.42" y2="17.49"></line>
  <line x1="15.41" y1="6.51" x2="8.59" y2="10.49"></line>
</svg>
''';

/// Day 4: Individual Post Card component
/// Displays a single post's title, body preview, author, tag, and vote count
/// Styled dynamically to align with the uniConnect Figma specifications
class PostCard extends StatelessWidget {
  final PostEntity post;
  final VoidCallback onTap;
  final VoidCallback onProfileTap;
  final VoidCallback onUpvote;
  final VoidCallback onDownvote;
  final VoidCallback? onDelete;
  final bool isUpvoted;
  final bool isDownvoted;
  final bool isLightMode;

  const PostCard({
    Key? key,
    required this.post,
    required this.onTap,
    required this.onProfileTap,
    required this.onUpvote,
    required this.onDownvote,
    this.onDelete,
    this.isUpvoted = false,
    this.isDownvoted = false,
    required this.isLightMode,
  }) : super(key: key);

  String getInitials(String name) {
    final cleanName = name.contains('@') ? name.split('@').first : name;
    if (cleanName.trim().isEmpty) return '?';
    final parts = cleanName.trim().split(RegExp(r'[\s._-]+'));
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return cleanName[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final brandColor = const Color(0xFF6139ED);
    final cardColor = isLightMode ? Colors.white : const Color(0xFF1E1E1E);
    final textColor = isLightMode ? Colors.black87 : Colors.white;
    final subTextColor = isLightMode ? Colors.grey[600] : Colors.grey[400];
    final authorName = post.authorName.contains('@')
        ? post.authorName.split('@').first
        : post.authorName;
    final initials = getInitials(post.authorName);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isLightMode
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
          border: Border.all(
            color: isLightMode ? Colors.grey[100]! : Colors.grey[850]!,
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Header Row
            Row(
              children: [
                GestureDetector(
                  onTap: onProfileTap,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: brandColor.withOpacity(0.15),
                    child: Text(
                      initials,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: brandColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authorName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Posted • ${formatTimeAgo(post.createdAt)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: subTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                // Tag & Delete Button
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: brandColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '#${post.tag}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: brandColor,
                        ),
                      ),
                    ),
                    if (onDelete != null) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: onDelete,
                        icon: Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: Colors.red[400],
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

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
            const SizedBox(height: 6),

            // Post Body
            Text(
              post.body,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                height: 1.5,
                color: subTextColor,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            if (post.imageUrl != null && post.imageUrl!.isNotEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  width: double.infinity,
                  child: Image.asset(
                    'assets/Screenshot 2026-07-24 111253.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 14),

            // Actions Bottom Row
            Row(
              children: [
                // 1. Like Button
                GestureDetector(
                  onTap: onUpvote,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/posts_screen_assets/like_button.png',
                        width: 20,
                        height: 20,
                        color: isUpvoted
                            ? Colors.redAccent
                            : (isLightMode
                                ? Colors.grey[600]
                                : Colors.grey[400]),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        post.upvotes.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color:
                              isLightMode ? Colors.grey[600] : Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),

                // 2. Comment Button
                GestureDetector(
                  onTap: onTap,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/posts_screen_assets/comment_icon.png',
                        width: 20,
                        height: 20,
                        color:
                            isLightMode ? Colors.grey[600] : Colors.grey[400],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        post.commentCount.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color:
                              isLightMode ? Colors.grey[600] : Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),

                // 3. Share Button
                GestureDetector(
                  onTap: () {
                    Share.share(
                        'Check out this post on CampusConnect:\n\n${post.title}\n${post.body}');
                  },
                  child: Image.asset(
                    'assets/posts_screen_assets/share_button.png',
                    width: 20,
                    height: 20,
                    color: isLightMode ? Colors.grey[600] : Colors.grey[400],
                  ),
                ),
                const Spacer(),

                // 4. Save Button
                GestureDetector(
                  onTap: () {
                    Get.snackbar(
                      'Saved',
                      'Post saved to your bookmarks!',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: brandColor,
                      colorText: Colors.white,
                      duration: const Duration(seconds: 2),
                    );
                  },
                  child: Image.asset(
                    'assets/posts_screen_assets/save_icon.png',
                    width: 20,
                    height: 20,
                    color: brandColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
