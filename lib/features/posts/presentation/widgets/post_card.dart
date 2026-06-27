import 'package:flutter/material.dart';
import 'package:noteswap/features/posts/domain/entities/post_entity.dart';

/// Day 4: Individual Post Card component
/// Displays a single post's title, body preview, author, tag, and vote count
/// Similar to a Reddit post card layout
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isLightMode ? Colors.white : const Color(0xFF1E1E1E),
          border: Border.all(
            color: isLightMode ? Colors.grey[300]! : Colors.grey[700]!,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author & Tag Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    post.authorName,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isLightMode ? Colors.black87 : Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: onProfileTap,
                  icon: Icon(
                    Icons.account_circle_outlined,
                    size: 20,
                    color: isLightMode ? Colors.black87 : Colors.white,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                if (onDelete != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: onDelete,
                    icon: Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: Colors.red[400],
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6139ED).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '#${post.tag}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6139ED),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Post Title
            Text(
              post.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isLightMode ? Colors.black : Colors.white,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),

            // Post Body Preview (truncated)
            Text(
              post.body,
              style: TextStyle(
                fontSize: 13,
                color: isLightMode ? Colors.grey[600] : Colors.grey[400],
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (post.imageUrl != null && post.imageUrl!.isNotEmpty) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 250),
                  width: double.infinity,
                  child: Image.network(
                    post.imageUrl!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 150,
                        color: isLightMode ? Colors.grey[200] : Colors.grey[850],
                        child: const Center(
                          child: CircularProgressIndicator(color: Color(0xFF6139ED)),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      color: isLightMode ? Colors.grey[100] : Colors.grey[900],
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, color: Colors.grey),
                          SizedBox(width: 8),
                          Text('Could not load image', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 10),

            // Vote & Comment Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Vote Section
                Row(
                  children: [
                    // Upvote Button
                    GestureDetector(
                      onTap: onUpvote,
                      child: Icon(
                        Icons.arrow_upward,
                        size: 20,
                        color: isUpvoted
                            ? const Color(0xFF6139ED)
                            : (isLightMode ? Colors.grey[600] : Colors.grey[400]),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      post.upvotes.toString(),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isLightMode ? Colors.black : Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Downvote Button
                    GestureDetector(
                      onTap: onDownvote,
                      child: Icon(
                        Icons.arrow_downward,
                        size: 20,
                        color: isDownvoted
                            ? const Color(0xFF6139ED)
                            : (isLightMode ? Colors.grey[600] : Colors.grey[400]),
                      ),
                    ),
                  ],
                ),

                // Comment Count
                Row(
                  children: [
                    Icon(
                      Icons.comment,
                      size: 18,
                      color: isLightMode ? Colors.grey[600] : Colors.grey[400],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      post.commentCount.toString(),
                      style: TextStyle(
                        fontSize: 13,
                        color: isLightMode ? Colors.grey[600] : Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
