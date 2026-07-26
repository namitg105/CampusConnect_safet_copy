import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

class MessageBubble extends StatelessWidget {
  final String sender;
  final String text;
  final String type;
  final String? mediaUrl;
  final String? senderImage;
  final DateTime timestamp;
  final bool isMe;
  final Map<String, dynamic>? reactions; // Saved reactions field

  const MessageBubble({
    super.key,
    required this.sender,
    required this.text,
    required this.type,
    this.mediaUrl,
    this.senderImage,
    required this.timestamp,
    this.isMe = false,
    this.reactions,
  });

  static const double mediaWidth = 240;
  static const double mediaHeight = 170;

  IconData _documentIcon(String fileName) {
    final name = fileName.toLowerCase();
    if (name.endsWith(".pdf")) return Icons.picture_as_pdf_rounded;
    if (name.endsWith(".doc") || name.endsWith(".docx")) {
      return Icons.description_rounded;
    }
    if (name.endsWith(".xls") || name.endsWith(".xlsx")) {
      return Icons.table_chart_rounded;
    }
    if (name.endsWith(".ppt") || name.endsWith(".pptx")) {
      return Icons.slideshow_rounded;
    }
    return Icons.insert_drive_file_rounded;
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? "PM" : "AM";
    return "${hour == 0 ? 12 : hour}:$minute $period";
  }

  Widget _buildReactionBadge(Map<String, dynamic> reactionsMap) {
    final uniqueEmojis = reactionsMap.values.toSet().toList();

    return Container(
      margin: const EdgeInsets.only(top: 4, bottom: 2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            uniqueEmojis.join(),
            style: const TextStyle(fontSize: 13),
          ),
          if (reactionsMap.length > 1) ...[
            const SizedBox(width: 4),
            Text(
              '${reactionsMap.length}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasValidImage = senderImage != null && senderImage!.trim().isNotEmpty;
    final hasReactions = reactions != null && reactions!.isNotEmpty;

    // Shared Dynamic Border Radius
    final bubbleRadius = BorderRadius.only(
      topLeft: const Radius.circular(20),
      topRight: const Radius.circular(20),
      bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(20),
      bottomLeft: isMe ? const Radius.circular(20) : const Radius.circular(4),
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Picture Segment (Only for incoming messages)
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFF0EFFF),
              backgroundImage:
                  hasValidImage ? NetworkImage(senderImage!.trim()) : null,
              child: !hasValidImage
                  ? Text(
                      sender.isNotEmpty ? sender[0].toUpperCase() : "U",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF6B4EFF),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
          ],

          // Content Segment
          Expanded(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Sender Details Header
                Padding(
                  padding: const EdgeInsets.only(left: 2, right: 2, bottom: 6),
                  child: Row(
                    mainAxisAlignment:
                        isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      if (!isMe) ...[
                        Text(
                          sender,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Color(0xFF1A1A1E),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _formatTime(timestamp),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.black.withOpacity(0.35),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ] else ...[
                        Text(
                          "You",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: const Color(0xFF6B4EFF).withOpacity(0.85),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _formatTime(timestamp),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.black.withOpacity(0.35),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Dynamic Alignment Box
                Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: isMe
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      // TEXT CONTEXT BUBBLE
                      if (type == "text")
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6B4EFF),
                            borderRadius: bubbleRadius,
                          ),
                          child: Text(
                            text,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14.5,
                              height: 1.4,
                            ),
                          ),
                        ),

                      // IMAGE CONTEXT BUBBLE
                      if (type == "image" && mediaUrl != null)
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    FullScreenImagePage(imageUrl: mediaUrl!),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: bubbleRadius,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: bubbleRadius,
                              child: SizedBox(
                                width: mediaWidth,
                                height: mediaHeight,
                                child: Image.network(
                                  mediaUrl!,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      color: const Color(0xFFF4F4F7),
                                      child: const Center(
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Color(0xFF6B4EFF)),
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (_, __, ___) => Container(
                                    color: const Color(0xFFF4F4F7),
                                    child: const Icon(
                                        Icons.broken_image_rounded,
                                        color: Colors.black26),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                      // VIDEO CONTEXT BUBBLE
                      if (type == "video" && mediaUrl != null)
                        VideoPlayerWidget(
                            url: mediaUrl!, bubbleRadius: bubbleRadius),

                      // DOCUMENT CONTEXT BUBBLE
                      if (type == "document" && mediaUrl != null)
                        InkWell(
                          borderRadius: bubbleRadius,
                          onTap: () async {
                            final uri = Uri.parse(mediaUrl!);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri,
                                  mode: LaunchMode.externalApplication);
                            }
                          },
                          child: Container(
                            width: 280,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color:
                                  isMe ? const Color(0xFFF0EFFF) : Colors.white,
                              borderRadius: bubbleRadius,
                              border: Border.all(
                                  color: isMe
                                      ? const Color(0xFFDED9FF)
                                      : const Color(0xFFEBEBEF),
                                  width: 1),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: isMe
                                        ? Colors.white
                                        : const Color(0xFFF0EFFF),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(
                                    _documentIcon(text),
                                    color: const Color(0xFF6B4EFF),
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        text,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13.5,
                                          color: Color(0xFF1A1A1E),
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        "Document File",
                                        style: TextStyle(
                                          color: Colors.black.withOpacity(0.4),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Colors.black.withOpacity(0.25),
                                  size: 14,
                                ),
                              ],
                            ),
                          ),
                        ),

                      // EMOJI REACTION BADGE DISPLAY
                      if (hasReactions) _buildReactionBadge(reactions!),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String url;
  final BorderRadius bubbleRadius;

  const VideoPlayerWidget(
      {super.key, required this.url, required this.bubbleRadius});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController controller;
  static const double mediaWidth = 240;
  static const double mediaHeight = 170;

  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        if (mounted) setState(() {});
      });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container(
        width: mediaWidth,
        height: mediaHeight,
        decoration: BoxDecoration(
          color: const Color(0xFFF4F4F7),
          borderRadius: widget.bubbleRadius,
        ),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: Color(0xFF6B4EFF)),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: widget.bubbleRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: widget.bubbleRadius,
        child: SizedBox(
          width: mediaWidth,
          height: mediaHeight,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: controller.value.size.width,
                    height: controller.value.size.height,
                    child: VideoPlayer(controller),
                  ),
                ),
              ),
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.15),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    controller.value.isPlaying
                        ? controller.pause()
                        : controller.play();
                  });
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 12,
                        )
                      ]),
                  child: Icon(
                    controller.value.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: const Color(0xFF1A1A1E),
                    size: 26,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FullScreenImagePage extends StatelessWidget {
  final String imageUrl;
  const FullScreenImagePage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white, size: 26),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image_rounded,
                color: Colors.white38, size: 40),
          ),
        ),
      ),
    );
  }
}
