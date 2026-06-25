import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noteswap/features/auth/domain/entities/app_user.dart';
import 'package:noteswap/features/posts/domain/entities/post_entity.dart';
import 'package:noteswap/features/posts/presentation/controllers/post_controller.dart';

class PostDetailPage extends StatefulWidget {
  final PostEntity post;
  final PostController controller;
  final AppUser currentUser;

  const PostDetailPage({super.key, required this.post, required this.controller, required this.currentUser});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final commentController = TextEditingController();

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.loadComments(widget.post.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.post.title)),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(widget.post.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(widget.post.body),
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
                Text('by ${widget.post.authorName} • #${widget.post.tag}'),
                const SizedBox(height: 20),
                const Text('Comments', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Obx(() {
                  final comments = widget.controller.comments;
                  if (comments.isEmpty) {
                    return const Text('No comments yet');
                  }
                  return Column(
                    children: comments.map((comment) {
                      final isMine = comment.authorId == widget.currentUser.uid;
                      return Card(
                        child: ListTile(
                          title: Text(comment.authorName),
                          subtitle: Text(comment.text),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.favorite,
                                  color: widget.controller.getCommentLikeState(comment.id) ? Colors.red : Colors.grey,
                                ),
                                onPressed: () => widget.controller.toggleCommentLike(
                                  widget.post.id,
                                  comment.id,
                                  widget.currentUser.uid,
                                ),
                              ),
                              if (isMine)
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => widget.controller.removeComment(
                                    postId: widget.post.id,
                                    commentId: comment.id,
                                    userId: widget.currentUser.uid,
                                    author: widget.currentUser,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: commentController,
                    decoration: const InputDecoration(hintText: 'Write a comment...', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    if (commentController.text.trim().isEmpty) return;
                    await widget.controller.submitComment(
                      postId: widget.post.id,
                      authorId: widget.currentUser.uid,
                      authorName: widget.currentUser.name.isNotEmpty ? widget.currentUser.name : widget.currentUser.email,
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
  }
}
