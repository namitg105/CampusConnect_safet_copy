import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:noteswap/features/auth/domain/entities/app_user.dart';
import 'package:noteswap/features/posts/domain/entities/comment_entity.dart';
import 'package:noteswap/features/posts/domain/entities/post_entity.dart';
import 'package:noteswap/features/posts/presentation/controllers/post_controller.dart';
import 'package:noteswap/ViewModels/DarkModeViewModels.dart';
import 'package:noteswap/utils/time_formatter.dart';
import 'package:share_plus/share_plus.dart';

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
  final AppUser currentUser;

  const PostDetailPage({
    super.key,
    required this.post,
    required this.controller,
    required this.currentUser,
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

  PostEntity get _latestPost {
    final idx = widget.controller.posts.indexWhere((p) => p.id == widget.post.id);
    if (idx != -1) {
      return widget.controller.posts[idx];
    }
    final tIdx = widget.controller.trendingPosts.indexWhere((p) => p.id == widget.post.id);
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
      widget.controller.loadComments(widget.post.id, widget.currentUser.uid);
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

    // Sort replies recursively by creation date ascending
    void sortReplies(CommentNode node) {
      node.replies
          .sort((a, b) => a.comment.createdAt.compareTo(b.comment.createdAt));
      for (final reply in node.replies) {
        sortReplies(reply);
      }
    }

    rootNodes
        .sort((a, b) => a.comment.createdAt.compareTo(b.comment.createdAt));
    for (final root in rootNodes) {
      sortReplies(root);
    }

    // Flatten tree and apply collapsed states
    final List<FlattenedComment> list = [];
    void flatten(List<CommentNode> nodes, int depth, bool parentCollapsed) {
      for (final node in nodes) {
        final isSelfCollapsed = collapsedCommentIds.contains(node.comment.id);

        // Only show if no parent in the hierarchy is collapsed
        if (!parentCollapsed) {
          list.add(FlattenedComment(node.comment, depth, isSelfCollapsed));
        }

        // Recursively traverse children, passing down the collapsed state
        flatten(node.replies, depth + 1, parentCollapsed || isSelfCollapsed);
      }
    }

    flatten(rootNodes, 0, false);

    return list;
  }

  void _confirmDeleteComment(String commentId) {
    showDialog(
      context: context,
      builder: (context) {
        final isLightMode = lightModeController.isLightMode.value;
        return AlertDialog(
          backgroundColor: isLightMode ? Colors.white : const Color(0xFF1E1E1E),
          title: Text(
            'Delete Comment',
            style: TextStyle(color: isLightMode ? Colors.black : Colors.white),
          ),
          content: Text(
            'Are you sure you want to delete this comment?',
            style:
                TextStyle(color: isLightMode ? Colors.black87 : Colors.white70),
          ),
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
                await widget.controller.removeComment(
                  postId: widget.post.id,
                  commentId: commentId,
                  userId: widget.currentUser.uid,
                  author: widget.currentUser,
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
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
    return Obx(() {
      final isLightMode = lightModeController.isLightMode.value;

      // Theme colors matching Figma Specifications
      final backgroundColor =
          isLightMode ? const Color(0xFFF4F1FC) : const Color(0xFF121214);
      final cardColor = isLightMode ? Colors.white : const Color(0xFF1E1E22);
      final textColor = isLightMode ? const Color(0xFF1A1A1E) : Colors.white;
      final subTextColor =
          isLightMode ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF);
      final brandColor = const Color(0xFF6139ED);

      final authorInitials = getInitials(widget.post.authorName);
      final authorName = widget.post.authorName.contains('@')
          ? widget.post.authorName.split('@').first
          : widget.post.authorName;

      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: textColor),
            onPressed: () => Navigator.maybePop(context),
          ),
          title: Text(
            'Post Details',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  // Main Post Details Card
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
                        color:
                            isLightMode ? Colors.grey[100]! : Colors.grey[850]!,
                        width: 0.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Post Header row
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: brandColor.withOpacity(0.15),
                              child: Text(
                                authorInitials,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: brandColor,
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
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Posted • ${formatTimeAgo(widget.post.createdAt)}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: subTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.more_horiz, color: subTextColor),
                              onPressed: () {},
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Post Body text
                        Text(
                          widget.post.body,
                          style: TextStyle(
                            fontSize: 14,
                            color: textColor,
                            height: 1.5,
                          ),
                        ),

                        // Post image
                        if (widget.post.imageUrl != null &&
                            widget.post.imageUrl!.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              'assets/Screenshot 2026-07-24 111253.png',
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),

                        // Actions Row matching Figma specs
                        Obx(() {
                          final currentPost = _latestPost;
                          return Row(
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
                                      onTap: () => widget.controller.toggleUpvote(
                                        currentPost.id,
                                        widget.currentUser.uid,
                                        widget.currentUser,
                                      ),
                                      child: SvgPicture.string(
                                        upvoteSvg,
                                        width: 15,
                                        height: 15,
                                        colorFilter: ColorFilter.mode(
                                          widget.controller.isPostUpvoted(currentPost.id)
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
                                        widget.currentUser.uid,
                                        widget.currentUser,
                                      ),
                                      child: SvgPicture.string(
                                        downvoteSvg,
                                        width: 15,
                                        height: 15,
                                        colorFilter: ColorFilter.mode(
                                          widget.controller.isPostDownvoted(currentPost.id)
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

                              // Comments section (NO capsule background)
                              Row(
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
                                    currentPost.commentCount.toString(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isLightMode ? Colors.grey[600] : Colors.grey[400],
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),

                              // Share Action (NO capsule background)
                              GestureDetector(
                                onTap: () {
                                  Share.share('Check out this post on CampusConnect:\n\n${currentPost.title}\n${currentPost.body}');
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
                                        color: isLightMode ? Colors.grey[600] : Colors.grey[400],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Comments section title in bold purple
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 12),
                    child: Obx(() {
                      final currentPost = _latestPost;
                      return Text(
                        '${currentPost.commentCount} COMMENTS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isLightMode
                              ? const Color(0xFF8858F2)
                              : const Color(0xFFA78BFA),
                          letterSpacing: 0.5,
                        ),
                      );
                    }),
                  ),

                  // Nested comments listing
                  Obx(() {
                    final flatComments = widget.controller.comments;
                    if (flatComments.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            'No comments yet',
                            style: TextStyle(color: subTextColor, fontSize: 13),
                          ),
                        ),
                      );
                    }

                    final flattenedList = _buildFlattenedComments(flatComments);

                    return Column(
                      children: flattenedList.map((item) {
                        final comment = item.comment;
                        final depth = item.depth;
                        final isCollapsed = item.isCollapsed;
                        final isMine =
                            comment.authorId == widget.currentUser.uid;
                        final commentInitials = getInitials(comment.authorName);
                        final commentAuthor = comment.authorName.contains('@')
                            ? comment.authorName.split('@').first
                            : comment.authorName;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Depth indentation line guide
                              for (int i = 0; i < depth; i++)
                                Container(
                                  width: 1.5,
                                  margin: const EdgeInsets.only(
                                      left: 12, right: 12, top: 0, bottom: 0),
                                  color: isLightMode
                                      ? Colors.grey[300]!
                                      : Colors.grey[800]!,
                                ),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Row with Avatar, Name, Time, Menu
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: depth == 0 ? 16 : 13,
                                          backgroundColor: _getAvatarColor(comment.authorName),
                                          child: Text(
                                            commentInitials,
                                            style: TextStyle(
                                              fontSize: depth == 0 ? 11 : 9,
                                              fontWeight: FontWeight.bold,
                                              color: _getAvatarTextColor(comment.authorName),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          commentAuthor,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13.5,
                                            color: textColor,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          formatTimeAgo(comment.createdAt),
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: subTextColor,
                                          ),
                                        ),
                                        const Spacer(),
                                        if (isMine)
                                          IconButton(
                                            icon: const Icon(
                                                Icons.delete_outline,
                                                size: 16,
                                                color: Colors.red),
                                            onPressed: () =>
                                                _confirmDeleteComment(
                                                    comment.id),
                                            padding: EdgeInsets.zero,
                                            constraints:
                                                const BoxConstraints(),
                                          )
                                        else
                                          Icon(Icons.more_horiz,
                                              size: 16, color: subTextColor.withOpacity(0.6)),
                                      ],
                                    ),
                                    
                                    // Comment body & actions, aligned with name
                                    Padding(
                                      padding: const EdgeInsets.only(left: 40),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 4),
                                          Text(
                                            comment.text,
                                            style: TextStyle(
                                              fontSize: 13.5,
                                              color: isLightMode ? Colors.black87 : Colors.white,
                                              height: 1.4,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          
                                          // Actions: Upvote arrow & Hide button
                                          Row(
                                            children: [
                                              GestureDetector(
                                                onTap: () => widget.controller.toggleCommentLike(
                                                  widget.post.id,
                                                  comment.id,
                                                  widget.currentUser.uid,
                                                ),
                                                child: Row(
                                                  children: [
                                                    SvgPicture.string(
                                                      upvoteSvg,
                                                      width: 14,
                                                      height: 14,
                                                      colorFilter: ColorFilter.mode(
                                                        widget.controller.getCommentLikeState(comment.id)
                                                            ? brandColor
                                                            : subTextColor,
                                                        BlendMode.srcIn,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      comment.likes.toString(),
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color: widget.controller.getCommentLikeState(comment.id)
                                                            ? brandColor
                                                            : subTextColor,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              
                                              // Collapsible Toggle text button
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    if (isCollapsed) {
                                                      collapsedCommentIds.remove(comment.id);
                                                    } else {
                                                      collapsedCommentIds.add(comment.id);
                                                    }
                                                  });
                                                },
                                                child: Text(
                                                  isCollapsed ? 'Show' : 'Hide',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: brandColor,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              
                                              // Reply hook trigger
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    replyingToComment = comment;
                                                  });
                                                  focusNode.requestFocus();
                                                },
                                                child: Text(
                                                  'Reply',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                    color: subTextColor,
                                                  ),
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
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  }),
                ],
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
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: brandColor.withOpacity(0.15),
                    child: Text(
                      getInitials(widget.currentUser.name.isNotEmpty
                          ? widget.currentUser.name
                          : widget.currentUser.email),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: brandColor,
                      ),
                    ),
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
                        authorId: widget.currentUser.uid,
                        authorName: widget.currentUser.name.isNotEmpty
                            ? widget.currentUser.name
                            : (widget.currentUser.email.contains('@')
                                ? widget.currentUser.email.split('@').first
                                : widget.currentUser.email),
                        text: text,
                        parentId: parentId,
                        author: widget.currentUser,
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
