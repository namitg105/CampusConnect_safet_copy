import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noteswap/features/auth/domain/entities/app_user.dart';
import 'package:noteswap/features/posts/domain/entities/comment_entity.dart';
import 'package:noteswap/features/posts/domain/entities/post_entity.dart';
import 'package:noteswap/features/posts/presentation/controllers/post_controller.dart';
import 'package:noteswap/ViewModels/DarkModeViewModels.dart';

class CommentNode {
  final CommentEntity comment;
  final List<CommentNode> replies = [];

  CommentNode(this.comment);
}

class FlattenedComment {
  final CommentEntity comment;
  final int depth;

  FlattenedComment(this.comment, this.depth);
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
  final LightModeController lightModeController = Get.find<LightModeController>();

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.loadComments(widget.post.id, widget.currentUser.uid);
    });
  }

  List<FlattenedComment> _buildFlattenedComments(List<CommentEntity> flatComments) {
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
      node.replies.sort((a, b) => a.comment.createdAt.compareTo(b.comment.createdAt));
      for (final reply in node.replies) {
        sortReplies(reply);
      }
    }

    rootNodes.sort((a, b) => a.comment.createdAt.compareTo(b.comment.createdAt));
    for (final root in rootNodes) {
      sortReplies(root);
    }

    // Flatten tree
    final List<FlattenedComment> list = [];
    void flatten(List<CommentNode> nodes, int depth) {
      for (final node in nodes) {
        list.add(FlattenedComment(node.comment, depth));
        flatten(node.replies, depth + 1);
      }
    }
    flatten(rootNodes, 0);

    return list;
  }

  void _showReplyDialog(CommentEntity parentComment) {
    final replyController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        final isLightMode = lightModeController.isLightMode.value;
        return AlertDialog(
          backgroundColor: isLightMode ? Colors.white : const Color(0xFF1E1E1E),
          title: Text(
            'Reply to ${parentComment.authorName}',
            style: TextStyle(color: isLightMode ? Colors.black : Colors.white),
          ),
          content: TextField(
            controller: replyController,
            style: TextStyle(color: isLightMode ? Colors.black : Colors.white),
            decoration: InputDecoration(
              hintText: 'Write your reply...',
              hintStyle: TextStyle(color: isLightMode ? Colors.grey : Colors.grey[400]),
              border: const OutlineInputBorder(),
            ),
            maxLines: 3,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6139ED),
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final text = replyController.text.trim();
                if (text.isNotEmpty) {
                  await widget.controller.submitComment(
                    postId: widget.post.id,
                    authorId: widget.currentUser.uid,
                    authorName: widget.currentUser.name.isNotEmpty 
                        ? widget.currentUser.name 
                        : widget.currentUser.email,
                    text: text,
                    parentId: parentComment.id,
                    author: widget.currentUser,
                  );
                  if (mounted) {
                    Navigator.pop(context);
                  }
                }
              },
              child: const Text('Reply'),
            ),
          ],
        );
      },
    );
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
            style: TextStyle(color: isLightMode ? Colors.black87 : Colors.white70),
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

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLightMode = lightModeController.isLightMode.value;
      return Scaffold(
        backgroundColor: isLightMode ? Colors.white : Colors.black,
        appBar: AppBar(
          backgroundColor: isLightMode ? Colors.black : Colors.white,
          iconTheme: IconThemeData(color: isLightMode ? Colors.white : Colors.black),
          title: Text(
            widget.post.title,
            style: TextStyle(
              color: isLightMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    widget.post.title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isLightMode ? Colors.black : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.post.body,
                    style: TextStyle(
                      fontSize: 14,
                      color: isLightMode ? Colors.black87 : Colors.white70,
                    ),
                  ),
                  if (widget.post.imageUrl != null && widget.post.imageUrl!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        widget.post.imageUrl!,
                        fit: BoxFit.contain,
                        width: double.infinity,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    'by ${widget.post.authorName} • #${widget.post.tag}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isLightMode ? Colors.grey[600] : Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Comments',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isLightMode ? Colors.black : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(() {
                    final flatComments = widget.controller.comments;
                    if (flatComments.isEmpty) {
                      return Text(
                        'No comments yet',
                        style: TextStyle(
                          color: isLightMode ? Colors.grey[600] : Colors.grey[400],
                        ),
                      );
                    }

                    final flattenedList = _buildFlattenedComments(flatComments);

                    return Column(
                      children: flattenedList.map((item) {
                        final comment = item.comment;
                        final depth = item.depth;
                        final isMine = comment.authorId == widget.currentUser.uid;

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Thread indentation guide lines
                            for (int i = 0; i < depth; i++)
                              Container(
                                width: 2,
                                margin: const EdgeInsets.only(right: 12, top: 4, bottom: 4),
                                color: Colors.grey.withOpacity(0.3),
                              ),
                            
                            // Comment Card Box
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isLightMode ? Colors.grey[100] : const Color(0xFF1E1E1E),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isLightMode ? Colors.grey[300]! : Colors.grey[800]!,
                                    width: 0.5,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Author info & delete option
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          comment.authorName,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: isLightMode ? Colors.black : Colors.white,
                                          ),
                                        ),
                                        if (isMine)
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                                            onPressed: () => _confirmDeleteComment(comment.id),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    // Comment text
                                    Text(
                                      comment.text,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isLightMode ? Colors.black87 : Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    // Actions: Like/Likes Count and Reply
                                    Row(
                                      children: [
                                        // Liking
                                        GestureDetector(
                                          onTap: () => widget.controller.toggleCommentLike(
                                            widget.post.id,
                                            comment.id,
                                            widget.currentUser.uid,
                                          ),
                                          child: Icon(
                                            widget.controller.getCommentLikeState(comment.id)
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            size: 16,
                                            color: widget.controller.getCommentLikeState(comment.id)
                                                ? Colors.red
                                                : Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          comment.likes.toString(),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isLightMode ? Colors.grey[700] : Colors.grey[400],
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        
                                        // Reply button
                                        GestureDetector(
                                          onTap: () => _showReplyDialog(comment),
                                          child: const Row(
                                            children: [
                                              Icon(Icons.reply, size: 14, color: Colors.grey),
                                              SizedBox(width: 4),
                                              Text(
                                                'Reply',
                                                style: TextStyle(fontSize: 12, color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    );
                  }),
                ],
              ),
            ),
            
            // Bottom Text Field for Root Comments
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      style: TextStyle(color: isLightMode ? Colors.black : Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Write a comment...',
                        hintStyle: TextStyle(color: isLightMode ? Colors.grey : Colors.grey[400]),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: isLightMode ? Colors.grey[400]! : Colors.grey[800]!,
                          ),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF6139ED)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6139ED),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      if (commentController.text.trim().isEmpty) return;
                      await widget.controller.submitComment(
                        postId: widget.post.id,
                        authorId: widget.currentUser.uid,
                        authorName: widget.currentUser.name.isNotEmpty 
                            ? widget.currentUser.name 
                            : widget.currentUser.email,
                        text: commentController.text,
                        author: widget.currentUser,
                      );
                      commentController.clear();
                    },
                    child: const Text('Comment'),
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
