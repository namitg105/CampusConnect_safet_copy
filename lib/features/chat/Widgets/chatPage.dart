import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../community/presentation/pages/community_profile.dart';
import '../presentation/cubits/chat_cubit.dart';
import '../presentation/cubits/chat_states.dart';

class ChatTheme {
  static const Color primary = Color(0xFF6139ED);
  static const Color dark = Color(0xFF1A1A1E);
  static const Color muted = Color(0xFF8E8E93);
  static const Color subText = Color(0xFF6B7280);
  static const Color bg = Colors.white;
  static const Color bubbleBg = Color(0xFFF5F2FD);
  static const Color cardBg = Colors.white;
  static const Color online = Color(0xFF00E676);
  static const Color border = Color(0xFFEEEEEE);
}

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
  Size get preferredSize => const Size.fromHeight(64);

  Widget _buildInitialsAvatar(String name) {
    final cleanName = name.trim();
    String initials = "AI";
    if (cleanName.isNotEmpty) {
      final parts = cleanName.split(' ').where((s) => s.isNotEmpty).toList();
      if (parts.length >= 2) {
        initials = (parts[0][0] + parts[1][0]).toUpperCase();
      } else if (parts.isNotEmpty) {
        initials = parts[0][0].toUpperCase();
      }
    }
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: ChatTheme.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: ChatTheme.cardBg,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      shape: const Border(
        bottom: BorderSide(color: ChatTheme.border, width: 0.5),
      ),
      title: Row(
        children: [
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.arrow_back, color: ChatTheme.dark),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => Navigator.maybePop(context),
          ),
          const SizedBox(width: 8),
          GestureDetector(
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
                (groupImage != null && groupImage!.trim().isNotEmpty)
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          groupImage!.trim(),
                          width: 38,
                          height: 38,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildInitialsAvatar(groupName),
                        ),
                      )
                    : _buildInitialsAvatar(groupName),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      groupName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ChatTheme.dark,
                      ),
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
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isOnline
                                    ? ChatTheme.online
                                    : ChatTheme.muted,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              subTitleText,
                              style: const TextStyle(
                                fontSize: 11,
                                color: ChatTheme.subText,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Image.asset(
            'assets/chat_assets/Notified bell.png',
            width: 24,
            height: 24,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.notifications_none, color: ChatTheme.dark),
          ),
          onPressed: () {},
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded, color: ChatTheme.dark),
          onSelected: (value) {
            if (value == "leave") onLeave();
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: "leave",
              child: Row(
                children: [
                  Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
                  SizedBox(width: 10),
                  Text(
                    "Leave Group",
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

class ChatMessageList extends StatelessWidget {
  final String groupId;
  final ScrollController scrollController;
  final String adminId;
  final String currentUserId;

  const ChatMessageList({
    super.key,
    required this.groupId,
    required this.scrollController,
    required this.adminId,
    required this.currentUserId,
  });

  Widget _buildCircularAvatar(String? imagePath, String senderName) {
    final String initials = senderName.isNotEmpty
        ? senderName.trim().split(' ').map((e) => e[0]).take(2).join()
        : 'U';

    return ClipOval(
      child: imagePath != null && imagePath.trim().isNotEmpty
          ? Image.network(
              imagePath.trim(),
              width: 38,
              height: 38,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _avatarFallback(initials),
            )
          : _avatarFallback(initials),
    );
  }

  Widget _avatarFallback(String initials) {
    return CircleAvatar(
      radius: 19,
      backgroundColor: const Color(0xFFECE7FF),
      child: Text(
        initials,
        style: const TextStyle(
          color: ChatTheme.primary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildResourceCard(String text, String? mediaUrl) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4E0F3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFFECEB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'PDF',
                style: TextStyle(
                  color: Color(0xFFEB5757),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
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
                  text.isNotEmpty
                      ? text
                      : "Fine - tuning LLM's\nA complete guide.",
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: ChatTheme.dark,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Text(
                      'PDF',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: ChatTheme.subText,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 3,
                      height: 3,
                      decoration: const BoxDecoration(
                        color: ChatTheme.subText,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '2.4 MB',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: ChatTheme.subText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showMessageOptions(BuildContext context, dynamic msg,
      bool calculatedAdminStatus, bool isCurrentlyPinned) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                if (calculatedAdminStatus) ...[
                  ListTile(
                    leading: Icon(
                      isCurrentlyPinned
                          ? Icons.pin_drop_rounded
                          : Icons.push_pin_rounded,
                      color: ChatTheme.dark,
                    ),
                    title: Text(
                      isCurrentlyPinned ? 'Unpin Message' : 'Pin Message',
                      style: const TextStyle(
                        color: ChatTheme.dark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () async {
                      Navigator.pop(bottomSheetContext);
                      if (isCurrentlyPinned) {
                        await context
                            .read<ChatCubit>()
                            .unpinMessage(groupId: groupId);
                      } else {
                        await context.read<ChatCubit>().pinMessage(
                              groupId: groupId,
                              messageId: msg.id,
                            );
                      }
                    },
                  ),
                  const Divider(color: Color(0xFFF1F5F9), height: 16),
                ],
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded,
                      color: Colors.redAccent),
                  title: const Text(
                    'Delete Message',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(bottomSheetContext);
                    if (msg.senderId != currentUserId) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text("You can delete only your own messages."),
                        ),
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
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("groups")
          .doc(groupId)
          .snapshots(),
      builder: (context, groupSnapshot) {
        String dynamicAdminId = adminId;
        if (groupSnapshot.hasData && groupSnapshot.data!.exists) {
          final groupData = groupSnapshot.data!.data() as Map<String, dynamic>?;
          dynamicAdminId =
              groupData?['createdBy'] ?? groupData?['adminId'] ?? adminId;
        }

        final bool calculatedAdminStatus =
            (currentUserId.trim() == dynamicAdminId.trim());

        final groupData = groupSnapshot.data?.data() as Map<String, dynamic>?;
        final String? pinnedMessageId = groupData?['pinnedMessageId'];
        final bool hasValidPin = pinnedMessageId != null &&
            pinnedMessageId.isNotEmpty &&
            pinnedMessageId != 'null';

        return BlocBuilder<ChatCubit, ChatState>(
          builder: (context, state) {
            if (state is ChatLoading) {
              return const Center(
                child: CircularProgressIndicator(color: ChatTheme.primary),
              );
            }

            if (state is ChatError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }

            if (state is ChatLoaded) {
              if (state.messages.isEmpty) {
                return const Center(
                  child: Text(
                    "No messages yet. Start the conversation!",
                    style: TextStyle(
                      color: ChatTheme.subText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
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
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                itemCount: state.messages.length + 1,
                itemBuilder: (_, index) {
                  if (index == 0) {
                    return Center(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Today',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: ChatTheme.subText,
                          ),
                        ),
                      ),
                    );
                  }
                  final msg = state.messages[index - 1];
                  final bool isPinned =
                      hasValidPin && msg.id == pinnedMessageId;
                  final bool isMe = msg.senderId == currentUserId;
                  final bool hasAttachment = msg.type != 'text' ||
                      (msg.mediaUrl != null &&
                          msg.mediaUrl.toString().isNotEmpty);

                  final avatar =
                      _buildCircularAvatar(msg.senderImage, msg.senderName);

                  final dynamic rawTimestamp = msg.timestamp;
                  final DateTime? dateTime = rawTimestamp is Timestamp
                      ? rawTimestamp.toDate()
                      : (rawTimestamp is DateTime ? rawTimestamp : null);

                  final String timeString = dateTime != null
                      ? "${dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12}:${dateTime.minute.toString().padLeft(2, '0')} ${dateTime.hour >= 12 ? 'PM' : 'AM'}"
                      : '';
                  final List<Widget> headerItems = isMe
                      ? [
                          Text(timeString,
                              style: const TextStyle(
                                  fontSize: 11, color: ChatTheme.muted)),
                          const SizedBox(width: 8),
                          Text(
                            msg.senderName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: ChatTheme.dark,
                            ),
                          ),
                        ]
                      : [
                          Text(
                            msg.senderName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: ChatTheme.dark,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(timeString,
                              style: const TextStyle(
                                  fontSize: 11, color: ChatTheme.muted)),
                        ];

                  final chatBubbleContent = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        msg.text,
                        style: const TextStyle(
                          fontSize: 14,
                          color: ChatTheme.dark,
                          height: 1.4,
                        ),
                      ),
                      if (hasAttachment) ...[
                        const SizedBox(height: 8),
                        _buildResourceCard(msg.text, msg.mediaUrl),
                      ]
                    ],
                  );

                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    child: GestureDetector(
                      onLongPress: () => _showMessageOptions(
                        context,
                        msg,
                        calculatedAdminStatus,
                        isPinned,
                      ),
                      child: Row(
                        mainAxisAlignment: isMe
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: isMe
                            ? [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: headerItems,
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        decoration: const BoxDecoration(
                                          color: ChatTheme.bubbleBg,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(16),
                                            bottomLeft: Radius.circular(16),
                                            bottomRight: Radius.circular(16),
                                          ),
                                        ),
                                        child: chatBubbleContent,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                avatar,
                              ]
                            : [
                                avatar,
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: headerItems,
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        decoration: const BoxDecoration(
                                          color: ChatTheme.bubbleBg,
                                          borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(16),
                                            bottomLeft: Radius.circular(16),
                                            bottomRight: Radius.circular(16),
                                          ),
                                        ),
                                        child: chatBubbleContent,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                      ),
                    ),
                  );
                },
              );
            }

            return const SizedBox();
          },
        );
      },
    );
  }
}

class ChatInputBar extends StatefulWidget {
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
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  bool showAttachmentPanel = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: ChatTheme.cardBg,
            border: Border(
              top: BorderSide(color: ChatTheme.border, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    showAttachmentPanel = !showAttachmentPanel;
                  });
                },
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(color: ChatTheme.primary, width: 1.5),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: ChatTheme.primary,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: ChatTheme.bubbleBg,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: widget.controller,
                          style: const TextStyle(
                            fontSize: 13,
                            color: ChatTheme.dark,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Message in group...',
                            hintStyle: TextStyle(
                              fontSize: 13,
                              color: ChatTheme.subText,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          onSubmitted: (_) => widget.onSend(),
                        ),
                      ),
                      Image.asset(
                        'assets/chat_assets/Frame_Smilie.png',
                        width: 22,
                        height: 22,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                          Icons.sentiment_satisfied_alt_outlined,
                          color: ChatTheme.subText,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: widget.onSend,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: ChatTheme.bubbleBg,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/chat_assets/Frame_microphone.png',
                      width: 20,
                      height: 20,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.mic_none_outlined,
                        color: ChatTheme.subText,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showAttachmentPanel)
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: ChatTheme.cardBg,
              border: Border(
                top: BorderSide(color: ChatTheme.border, width: 0.5),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachmentOption(
                  iconPath: 'assets/chat_assets/Frame.png',
                  label: 'Photo',
                  bgColor: const Color(0xFFF0ECFC),
                  onTap: () {
                    setState(() => showAttachmentPanel = false);
                    widget.onPickImage();
                  },
                ),
                _buildAttachmentOption(
                  iconPath: 'assets/chat_assets/Frame_camera.png',
                  label: 'Video',
                  bgColor: const Color(0xFFFDF2F8),
                  onTap: () {
                    setState(() => showAttachmentPanel = false);
                    widget.onPickVideo();
                  },
                ),
                _buildAttachmentOption(
                  iconPath: 'assets/chat_assets/Frame_document.png',
                  label: 'Document',
                  bgColor: const Color(0xFFECFDF5),
                  onTap: () {
                    setState(() => showAttachmentPanel = false);
                    widget.onPickDocument();
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildAttachmentOption({
    required String iconPath,
    required String label,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset(
                iconPath,
                width: 24,
                height: 24,
                color: ChatTheme.primary,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.attach_file, color: ChatTheme.primary),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: ChatTheme.dark,
            ),
          ),
        ],
      ),
    );
  }
}
