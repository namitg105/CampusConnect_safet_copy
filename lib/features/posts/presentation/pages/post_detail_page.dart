import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:noteswap/features/auth/domain/entities/app_user.dart';
import 'package:noteswap/features/posts/domain/entities/comment_entity.dart';
import 'package:noteswap/features/posts/domain/entities/post_entity.dart';
import 'package:noteswap/features/posts/presentation/controllers/post_controller.dart';
import 'package:noteswap/ViewModels/DarkModeViewModels.dart';
import 'package:noteswap/utils/time_formatter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_fonts/google_fonts.dart';

// SVG Assets matching Figma specifications perfectly
const String upvoteSvg = '''
<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <line x1="12" y1="19" x2="12" y2="5"></line>
  <polyline points="5 12 12 5 19 12"></polyline>
</svg>''';

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

Color _getAvatarColor(String name) {
  final colors = [
    const Color(0xFFE0D7FF), // light purple
    const Color(0xFFC7F3FD), // light blue-green
    const Color(0xFFFEF08A), // light yellow
    const Color(0xFFFBCFE8), // light pink
    const Color(0xFFC7D2FE), // light indigo
  ];
  int hash = name.codeUnits.fold(0, (prev, elem) => prev + elem);
  return colors[hash % colors.length];
}

Color _getAvatarTextColor(String name) {
  final colors = [
    const Color(0xFF6139ED), // purple
    const Color(0xFF0D9488), // teal
    const Color(0xFFB45309), // amber
    const Color(0xFFBE185D), // pink
    const Color(0xFF4338CA), // indigo
  ];
  int hash = name.codeUnits.fold(0, (prev, elem) => prev + elem);
  return colors[hash % colors.length];
}

class CommentNode {
  final CommentEntity comment;
  final List<CommentNode> replies = [];

  CommentNode(this.comment);
}

class FlattenedComment {
  final CommentEntity comment;
  final int depth;
  final bool isCollapsed;

  FlattenedComment(this.comment, this.depth, this.isCollapsed);
}

class PostDetailPage extends StatefulWidget {
  final PostEntity post;
  final PostController controller;
  final AppUser? currentUser;

  const PostDetailPage({
    super.key,
    required this.post,
    required this.controller,
    this.currentUser,
  });

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final commentController = TextEditingController();
  final focusNode = FocusNode();
  final LightModeController lightModeController =
      Get.find<LightModeController>();

  // Track collapsed comment threads
  final Set<String> collapsedCommentIds = {};

  // Track which comment we are currently replying to (null for root post)
  CommentEntity? replyingToComment;

  AppUser get currentUser {
    if (widget.currentUser != null) return widget.currentUser!;
    final authUser = FirebaseAuth.instance.currentUser;
    return AppUser(
      uid: authUser?.uid ?? '',
      email: authUser?.email ?? '',
      name: authUser?.displayName ?? 'User',
      collegeId: authUser?.email?.split('@').last ?? '',
    );
  }

  PostEntity get _latestPost {
    final idx =
        widget.controller.posts.indexWhere((p) => p.id == widget.post.id);
    if (idx != -1) {
      return widget.controller.posts[idx];
    }
    final tIdx = widget.controller.trendingPosts
        .indexWhere((p) => p.id == widget.post.id);
    if (tIdx != -1) {
      return widget.controller.trendingPosts[tIdx];
    }
    return widget.post;
  }

  @override
  void dispose() {
    commentController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.loadComments(widget.post.id, currentUser.uid);
    });
  }

  List<FlattenedComment> _buildFlattenedComments(
      List<CommentEntity> flatComments) {
    final Map<String, CommentNode> nodeMap = {};
    final List<CommentNode> rootNodes = [];

    // Create nodes for all comments
    for (final comment in flatComments) {
      nodeMap[comment.id] = CommentNode(comment);
    }

    // Build relationships
    for (final comment in flatComments) {
      final node = nodeMap[comment.id]!;
      if (comment.parentId == null || comment.parentId!.isEmpty) {
        rootNodes.add(node);
      } else {
        final parentNode = nodeMap[comment.parentId];
        if (parentNode != null) {
          parentNode.replies.add(node);
        } else {
          rootNodes.add(node);
        }
      }
    }

    final List<FlattenedComment> result = [];

    void dfs(CommentNode node, int depth, bool isAncestorCollapsed) {
      final isSelfCollapsed = collapsedCommentIds.contains(node.comment.id);
      final currentCollapsedState = isAncestorCollapsed || isSelfCollapsed;

      result.add(FlattenedComment(node.comment, depth, isAncestorCollapsed));

      if (!isSelfCollapsed) {
        for (final reply in node.replies) {
          dfs(reply, depth + 1, currentCollapsedState);
        }
      }
    }

    for (final root in rootNodes) {
      dfs(root, 0, false);
    }

    return result;
  }

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

    return Obx(() {
      final isLightMode = lightModeController.isLightMode.value;
      final cardColor = isLightMode ? Colors.white : const Color(0xFF1E1E1E);
      final textColor = isLightMode ? Colors.black87 : Colors.white;
      final subTextColor = isLightMode ? Colors.grey[600]! : Colors.grey[400]!;

      final currentPost = _latestPost;
      final authorName = currentPost.authorName.contains('@')
          ? currentPost.authorName.split('@').first
          : currentPost.authorName;
      final initials = getInitials(currentPost.authorName);

      return Scaffold(
        backgroundColor:
            isLightMode ? const Color(0xFFF8F9FE) : const Color(0xFF121212),
        appBar: AppBar(
          backgroundColor: cardColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, size: 20, color: textColor),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Post Details',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main Post Card Container
                    Container(
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
                          color: isLightMode
                              ? Colors.grey[100]!
                              : Colors.grey[850]!,
                          width: 0.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // User Header Row
                          Row(
                            children: [
                              StreamBuilder<DocumentSnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(currentPost.authorId)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  final data = snapshot.data?.data()
                                      as Map<String, dynamic>?;
                                  final profileImageUrl =
                                      data?['profileImage'] as String?;
                                  final hasImage = profileImageUrl != null &&
                                      profileImageUrl.isNotEmpty;

                                  return CircleAvatar(
                                    radius: 18,
                                    backgroundColor:
                                        brandColor.withOpacity(0.15),
                                    backgroundImage: hasImage
                                        ? NetworkImage(profileImageUrl)
                                        : null,
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
                                      'Posted • ${formatTimeAgo(currentPost.createdAt)}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: subTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: brandColor.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '#${currentPost.tag}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: brandColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Post Title
                          Text(
                            currentPost.title,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              height: 1.45,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Full Post Body
                          Text(
                            currentPost.body,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              height: 1.55,
                              color: subTextColor,
                            ),
                          ),

                          // Attached Media rendering
                          if (currentPost.imageUrl != null &&
                              currentPost.imageUrl!.isNotEmpty) ...[
                            const SizedBox(height: 14),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                constraints:
                                    const BoxConstraints(maxHeight: 280),
                                width: double.infinity,
                                child: Image.network(
                                  currentPost.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    height: 140,
                                    color: isLightMode
                                        ? const Color(0xFFF3F4F6)
                                        : const Color(0xFF2D2D2D),
                                    child: const Center(
                                      child: Icon(
                                          Icons.image_not_supported_outlined,
                                          color: Colors.grey,
                                          size: 36),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),

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
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    GestureDetector(
                                      onTap: () =>
                                          widget.controller.toggleUpvote(
                                        currentPost.id,
                                        currentUser.uid,
                                        currentUser,
                                      ),
                                      child: SvgPicture.string(
                                        upvoteSvg,
                                        width: 15,
                                        height: 15,
                                        colorFilter: ColorFilter.mode(
                                          widget.controller
                                                  .isPostUpvoted(currentPost.id)
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
                                      currentPost.upvotes.toString(),
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
                                      color: isLightMode
                                          ? Colors.grey[300]
                                          : Colors.grey[600],
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () =>
                                          widget.controller.toggleDownvote(
                                        currentPost.id,
                                        currentUser.uid,
                                        currentUser,
                                      ),
                                      child: SvgPicture.string(
                                        downvoteSvg,
                                        width: 15,
                                        height: 15,
                                        colorFilter: ColorFilter.mode(
                                          widget.controller.isPostDownvoted(
                                                  currentPost.id)
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

                              // Comment Counter
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SvgPicture.string(
                                    commentSvg,
                                    width: 16,
                                    height: 16,
                                    colorFilter: ColorFilter.mode(
                                      subTextColor,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${widget.controller.comments.length} Comments',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: subTextColor,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),

                              // Share Button
                              GestureDetector(
                                onTap: () {
                                  Share.share(
                                      'Check out this post on CampusConnect:\n\n${currentPost.title}\n${currentPost.body}');
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SvgPicture.string(
                                      shareSvg,
                                      width: 16,
                                      height: 16,
                                      colorFilter: ColorFilter.mode(
                                        subTextColor,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Share',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: subTextColor,
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
                    const SizedBox(height: 20),

                    // Comments Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Text(
                        'Discussion (${widget.controller.comments.length})',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Nested Comments Thread View
                    if (widget.controller.comments.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32.0),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.chat_bubble_outline_rounded,
                                  size: 40,
                                  color: subTextColor.withOpacity(0.5)),
                              const SizedBox(height: 8),
                              Text(
                                'No comments yet. Start the conversation!',
                                style: TextStyle(
                                    color: subTextColor, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Builder(builder: (context) {
                        final flattened =
                            _buildFlattenedComments(widget.controller.comments);

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: flattened.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final item = flattened[index];
                            final comment = item.comment;
                            final depth = item.depth;
                            final isCollapsed = item.isCollapsed;
                            final isMine = comment.authorId == currentUser.uid;
                            final commentInitials =
                                getInitials(comment.authorName);
                            final commentAuthor =
                                comment.authorName.contains('@')
                                    ? comment.authorName.split('@').first
                                    : comment.authorName;

                            final isLiked =
                                widget.controller.isCommentLiked(comment.id);

                            if (isCollapsed) return const SizedBox.shrink();

                            return Padding(
                              padding: EdgeInsets.only(
                                  left: (depth * 20.0).clamp(0, 100)),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isLightMode
                                        ? Colors.grey[200]!
                                        : Colors.grey[850]!,
                                    width: 0.5,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Comment Author Row
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 12,
                                          backgroundColor:
                                              _getAvatarColor(commentAuthor),
                                          child: Text(
                                            commentInitials,
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: _getAvatarTextColor(
                                                  commentAuthor),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          commentAuthor,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: textColor,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '• ${formatTimeAgo(comment.createdAt)}',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: subTextColor,
                                          ),
                                        ),
                                        const Spacer(),
                                        if (isMine)
                                          IconButton(
                                            icon: Icon(Icons.delete_outline,
                                                size: 14,
                                                color: Colors.red[400]),
                                            onPressed: () {
                                              widget.controller.deleteComment(
                                                  widget.post.id, comment.id);
                                            },
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),

                                    // Comment Body
                                    Text(
                                      comment.text,
                                      style: TextStyle(
                                        fontSize: 13,
                                        height: 1.4,
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    // Actions: Like & Reply
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            widget.controller.toggleLikeComment(
                                                widget.post.id,
                                                comment.id,
                                                currentUser.uid);
                                          },
                                          child: Row(
                                            children: [
                                              Icon(
                                                isLiked
                                                    ? Icons.favorite
                                                    : Icons.favorite_border,
                                                size: 14,
                                                color: isLiked
                                                    ? Colors.red
                                                    : subTextColor,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${comment.likes}',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: subTextColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              replyingToComment = comment;
                                            });
                                            focusNode.requestFocus();
                                          },
                                          child: Row(
                                            children: [
                                              Icon(Icons.reply,
                                                  size: 14,
                                                  color: subTextColor),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Reply',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: subTextColor,
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
                          },
                        );
                      }),
                  ],
                ),
              ),
            ),

            // Replying to overlay indicator above bottom field
            if (replyingToComment != null)
              Container(
                color: isLightMode
                    ? const Color(0xFFECE7FF)
                    : const Color(0xFF221A3A),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.reply, size: 16, color: brandColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Replying to ${replyingToComment!.authorName.contains('@') ? replyingToComment!.authorName.split('@').first : replyingToComment!.authorName}',
                        style: TextStyle(
                          fontSize: 12,
                          color: brandColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          replyingToComment = null;
                        });
                      },
                      child: Icon(Icons.close, size: 16, color: brandColor),
                    ),
                  ],
                ),
              ),

            // Bottom Input Bar matching Figma specs
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: cardColor,
                boxShadow: [
                  BoxShadow(
                    color: brandColor.withOpacity(0.08),
                    blurRadius: 32,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(currentUser.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      final data =
                          snapshot.data?.data() as Map<String, dynamic>?;
                      final profileImageUrl = data?['profileImage'] as String?;
                      final hasImage =
                          profileImageUrl != null && profileImageUrl.isNotEmpty;

                      return CircleAvatar(
                        radius: 16,
                        backgroundColor: brandColor.withOpacity(0.15),
                        backgroundImage:
                            hasImage ? NetworkImage(profileImageUrl) : null,
                        child: hasImage
                            ? null
                            : Text(
                                getInitials(currentUser.name.isNotEmpty
                                    ? currentUser.name
                                    : currentUser.email),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: brandColor,
                                ),
                              ),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isLightMode
                            ? const Color(0xFFF3F4F6)
                            : const Color(0xFF2D2D2D),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: commentController,
                        focusNode: focusNode,
                        style: TextStyle(color: textColor, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: replyingToComment != null
                              ? 'Write a reply...'
                              : 'Write a comment...',
                          hintStyle:
                              TextStyle(color: subTextColor, fontSize: 13),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () async {
                      final text = commentController.text.trim();
                      if (text.isEmpty) return;

                      final parentId = replyingToComment?.id;

                      await widget.controller.submitComment(
                        postId: widget.post.id,
                        authorId: currentUser.uid,
                        authorName: currentUser.name.isNotEmpty
                            ? currentUser.name
                            : (currentUser.email.contains('@')
                                ? currentUser.email.split('@').first
                                : currentUser.email),
                        text: text,
                        parentId: parentId,
                        author: currentUser,
                      );

                      commentController.clear();
                      setState(() {
                        replyingToComment = null;
                      });
                      focusNode.unfocus();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Icon(
                        Icons.send_rounded,
                        size: 20,
                        color: commentController.text.trim().isEmpty
                            ? subTextColor.withOpacity(0.5)
                            : brandColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
