import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../community/presentation/pages/community_profile.dart';
import '../presentation/components/message_bubble.dart';
import '../presentation/cubits/chat_cubit.dart';
import '../presentation/cubits/chat_states.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String groupName;
  final String groupId;
  final String? groupImage;
  final VoidCallback onLeave;

  const ChatAppBar({
    super.key,
    required this.groupName,
    required this.groupId,
    required this.onLeave,
    this.groupImage,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 10);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
        onPressed: () => Navigator.maybePop(context),
      ),
      centerTitle: false,
      title: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GroupProfilePage(groupId: groupId),
            ),
          );
        },
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFF3F3F7),
              backgroundImage:
                  groupImage != null && groupImage!.trim().isNotEmpty
                      ? NetworkImage(groupImage!.trim())
                      : const AssetImage("assets/community/blue_profile.png")
                          as ImageProvider,
              onBackgroundImageError: (_, __) {},
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    groupName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  BlocBuilder<ChatCubit, ChatState>(
                    builder: (context, state) {
                      String subTitleText = "Connecting...";
                      bool isOnline = false;

                      if (state is ChatLoaded) {
                        final int onlineCount = 1;

                        isOnline = onlineCount > 0;

                        if (onlineCount <= 1) {
                          subTitleText = "Online · Only you";
                        } else {
                          subTitleText = "Online · $onlineCount active";
                        }
                      } else if (state is ChatError) {
                        subTitleText = "Disconnected";
                      }

                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: isOnline ? Colors.green : Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            subTitleText,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 28.0),
          child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF0EFFF),
                shape: BoxShape.circle,
              ),
              child: Image.asset("assets/community/reload.png")),
        ),
      ],
    );
  }
}

class ChatMessageList extends StatelessWidget {
  final String groupId;
  final ScrollController scrollController;

  const ChatMessageList({
    super.key,
    required this.groupId,
    required this.scrollController,
  });

  void _showMessageOptions(BuildContext context, dynamic msg) {
    final currentUserId = context.read<ChatCubit>().currentUserId;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F3F7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.reply, color: Colors.black87),
                  ),
                  title: const Text('Forward',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  onTap: () => Navigator.pop(bottomSheetContext),
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F3F7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.visibility_outlined,
                        color: Colors.black87),
                  ),
                  title: const Text('View info',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  onTap: () => Navigator.pop(bottomSheetContext),
                ),
                const Divider(height: 24),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEB),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.delete_outline,
                        color: Colors.redAccent),
                  ),
                  title: const Text(
                    'Delete message',
                    style: TextStyle(
                        color: Colors.redAccent, fontWeight: FontWeight.w500),
                  ),
                  onTap: () async {
                    Navigator.pop(bottomSheetContext);
                    if (msg.senderId != currentUserId) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text("You can delete only your own messages.")),
                      );
                      return;
                    }
                    await context.read<ChatCubit>().deleteMessage(
                          groupId: groupId,
                          messageId: msg.id,
                        );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        if (state is ChatLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ChatError) {
          return Center(child: Text(state.message));
        }

        if (state is ChatLoaded) {
          if (state.messages.isEmpty) {
            return const Center(
              child: Text("No messages yet", style: TextStyle(fontSize: 16)),
            );
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (scrollController.hasClients) {
              scrollController
                  .jumpTo(scrollController.position.maxScrollExtent);
            }
          });

          return ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: state.messages.length,
            itemBuilder: (_, index) {
              final msg = state.messages[index];

              return GestureDetector(
                onLongPress: () => _showMessageOptions(context, msg),
                child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: MessageBubble(
                      sender: msg.senderName,
                      senderImage: msg.senderImage,
                      text: msg.text,
                      type: msg.type,
                      mediaUrl: msg.mediaUrl,
                      timestamp: msg.timestamp,
                    )),
              );
            },
          );
        }

        return const SizedBox();
      },
    );
  }
}

class ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onPickImage;
  final VoidCallback onPickVideo;
  final VoidCallback onPickDocument;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onPickImage,
    required this.onPickVideo,
    required this.onPickDocument,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F3F7),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    PopupMenuButton<String>(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      icon: const Icon(
                        Icons.attach_file_rounded,
                        color: Colors.black54,
                        size: 22,
                      ),
                      onSelected: (value) {
                        switch (value) {
                          case "image":
                            onPickImage();
                            break;
                          case "video":
                            onPickVideo();
                            break;
                          case "document":
                            onPickDocument();
                            break;
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: "image",
                          child: Row(
                            children: [
                              Icon(Icons.image_outlined,
                                  color: Color(0xFF6B4EFF)),
                              SizedBox(width: 12),
                              Text("Photo"),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: "video",
                          child: Row(
                            children: [
                              Icon(Icons.videocam_outlined,
                                  color: Color(0xFF6B4EFF)),
                              SizedBox(width: 12),
                              Text("Video"),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: "document",
                          child: Row(
                            children: [
                              Icon(Icons.description_outlined,
                                  color: Color(0xFF6B4EFF)),
                              SizedBox(width: 12),
                              Text("Document"),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        minLines: 1,
                        maxLines: 4,
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: (_) => onSend(),
                        decoration: const InputDecoration(
                          hintText: "Type a message...",
                          hintStyle:
                              TextStyle(color: Colors.black38, fontSize: 14),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF6B4EFF),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send_rounded,
                    color: Colors.white, size: 18),
                onPressed: onSend,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
