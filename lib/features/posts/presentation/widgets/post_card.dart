import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:noteswap/features/posts/domain/entities/post_entity.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../utils/time_formatter.dart';

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
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(post.authorId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      final data =
                          snapshot.data?.data() as Map<String, dynamic>?;
                      final profileImageUrl = data?['profileImage'] as String?;
                      final hasImage =
                          profileImageUrl != null && profileImageUrl.isNotEmpty;

                      return CircleAvatar(
                        radius: 18,
                        backgroundColor: brandColor.withOpacity(0.15),
                        backgroundImage:
                            hasImage ? NetworkImage(profileImageUrl) : null,
                        child: hasImage
                            ? null
                            : Text(
                                initials,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: brandColor,
                                ),
                              ),
                      );
                    },
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
                // Upvote/Downvote Capsule
                Container(
                  decoration: BoxDecoration(
                    color: isLightMode
                        ? const Color(0xFFF3F4F6)
                        : const Color(0xFF2D2D2D),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: onUpvote,
                        child: SvgPicture.string(
                          upvoteSvg,
                          width: 15,
                          height: 15,
                          colorFilter: ColorFilter.mode(
                            isUpvoted
                                ? brandColor
                                : (isLightMode
                                    ? Colors.grey[600]!
                                    : Colors.grey[400]!),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        post.upvotes.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        height: 12,
                        width: 1,
                        color:
                            isLightMode ? Colors.grey[300] : Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: onDownvote,
                        child: SvgPicture.string(
                          downvoteSvg,
                          width: 15,
                          height: 15,
                          colorFilter: ColorFilter.mode(
                            isDownvoted
                                ? brandColor
                                : (isLightMode
                                    ? Colors.grey[600]!
                                    : Colors.grey[400]!),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                // Comment Count Capsule
                Container(
                  decoration: BoxDecoration(
                    color: isLightMode
                        ? const Color(0xFFF3F4F6)
                        : const Color(0xFF2D2D2D),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.string(
                        commentSvg,
                        width: 14,
                        height: 14,
                        colorFilter: ColorFilter.mode(
                          isLightMode ? Colors.grey[600]! : Colors.grey[400]!,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        post.commentCount.toString(),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                // Share Action Button (NO capsule background!)
                GestureDetector(
                  onTap: () {
                    Share.share(
                        'Check out this post on CampusConnect:\n\n${post.title}\n${post.body}');
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.string(
                        shareSvg,
                        width: 16,
                        height: 16,
                        colorFilter: ColorFilter.mode(
                          isLightMode ? Colors.grey[600]! : Colors.grey[400]!,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Share',
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
