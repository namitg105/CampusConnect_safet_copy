import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

/// Individual Post Card component
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
    super.key,
    required this.post,
    required this.onTap,
    required this.onProfileTap,
    required this.onUpvote,
    required this.onDownvote,
    this.onDelete,
    this.isUpvoted = false,
    this.isDownvoted = false,
    required this.isLightMode,
  });

  String getInitials(String name) {
    final cleanName = name.contains('@') ? name.split('@').first : name;
    if (cleanName.trim().isEmpty) return '?';
    final parts = cleanName.trim().split(RegExp(r'[\s._-]+'));
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return cleanName[0].toUpperCase();
  }

  Widget _buildMediaWidget(
      BuildContext context, PostEntity post, bool isLightMode) {
    if (post.imageUrl == null || post.imageUrl!.isEmpty) {
      return const SizedBox.shrink();
    }

    final mediaType = post.mediaType ?? 'image';

    if (mediaType == 'document') {
      return Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              isLightMode ? const Color(0xFFECE7FF) : const Color(0xFF2D2D2D),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF6139ED).withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.description, color: Color(0xFF6139ED), size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                post.mediaName ?? 'Attached Document',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isLightMode ? const Color(0xFF1A1A1E) : Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.download_rounded,
                color: Color(0xFF6139ED), size: 20),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 220),
          width: double.infinity,
          child: Image.network(
            post.imageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 120,
              color: isLightMode
                  ? const Color(0xFFF3F4F6)
                  : const Color(0xFF2D2D2D),
              child: const Center(
                child: Icon(Icons.image_not_supported_outlined,
                    color: Colors.grey, size: 36),
              ),
            ),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                height: 150,
                color: isLightMode
                    ? const Color(0xFFF3F4F6)
                    : const Color(0xFF2D2D2D),
                child: const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Color(0xFF6139ED)),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
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

            if (post.poll != null) ...[
              PollWidget(post: post, isLightMode: isLightMode),
            ],

            if (post.imageUrl != null && post.imageUrl!.isNotEmpty) ...[
              _buildMediaWidget(context, post, isLightMode),
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
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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

                // Comment Action Button
                GestureDetector(
                  onTap: onTap,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.string(
                        commentSvg,
                        width: 16,
                        height: 16,
                        colorFilter: ColorFilter.mode(
                          isLightMode ? Colors.grey[600]! : Colors.grey[400]!,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${post.commentCount} Comments',
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
                const Spacer(),

                // Share Action Button
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

class PollWidget extends StatefulWidget {
  final PostEntity post;
  final bool isLightMode;

  const PollWidget({
    super.key,
    required this.post,
    required this.isLightMode,
  });

  @override
  State<PollWidget> createState() => _PollWidgetState();
}

class _PollWidgetState extends State<PollWidget> {
  late PollData _poll;

  @override
  void initState() {
    super.initState();
    _poll = widget.post.poll!;
  }

  @override
  void didUpdateWidget(covariant PollWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.post.poll != null) {
      _poll = widget.post.poll!;
    }
  }

  void _vote(PollOption option, String currentUid) {
    if (currentUid.isEmpty) return;

    final isVoted = option.votes.contains(currentUid);
    final newOptions = _poll.options.map((opt) {
      final newVotes = List<String>.from(opt.votes);
      if (opt.text == option.text) {
        if (isVoted) {
          newVotes.remove(currentUid);
        } else {
          newVotes.add(currentUid);
        }
      } else {
        newVotes.remove(currentUid);
      }
      return PollOption(text: opt.text, votes: newVotes);
    }).toList();

    final updatedPoll = PollData(question: _poll.question, options: newOptions);

    // 1. INSTANT UI UPDATE (0ms delay)
    setState(() {
      _poll = updatedPoll;
    });

    // 2. BACKGROUND FIREBASE FIRESTORE SYNC
    FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.post.id)
        .update({'poll': updatedPoll.toJson()}).catchError((e) {
      // Background sync error handling
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final totalVotes = _poll.totalVotes;
    final isLightMode = widget.isLightMode;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isLightMode ? const Color(0xFFF8F9FE) : const Color(0xFF25252A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF6139ED).withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.poll_outlined,
                  color: Color(0xFF6139ED), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _poll.question,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isLightMode ? const Color(0xFF1A1A1E) : Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._poll.options.map((option) {
            final isVoted = option.votes.contains(currentUid);
            final percentage = totalVotes > 0
                ? (option.votes.length / totalVotes * 100).round()
                : 0;

            return GestureDetector(
              onTap: () => _vote(option, currentUid),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isVoted
                      ? const Color(0xFF6139ED).withOpacity(0.12)
                      : (isLightMode ? Colors.white : const Color(0xFF1E1E22)),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isVoted
                        ? const Color(0xFF6139ED)
                        : (isLightMode
                            ? const Color(0xFFE5E7EB)
                            : const Color(0xFF374151)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isVoted
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color:
                              isVoted ? const Color(0xFF6139ED) : Colors.grey,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          option.text,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight:
                                isVoted ? FontWeight.bold : FontWeight.w500,
                            color: isLightMode
                                ? const Color(0xFF1A1A1E)
                                : Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '$percentage%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6139ED),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 4),
          Text(
            '$totalVotes ${totalVotes == 1 ? 'vote' : 'votes'}',
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
