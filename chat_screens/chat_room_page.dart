import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noteswap/features/auth/domain/entities/app_user.dart';
import 'package:noteswap/features/chat/domain/entities/chat_room_entity.dart';
import 'package:noteswap/ViewModels/DarkModeViewModels.dart';

class LocalChatMessage {
  final String senderName;
  final String time;
  final String text;
  final bool isMine;
  final String avatarPath;
  final String initials;
  final String? reaction;
  final int? reactionCount;
  final bool hasAttachment;

  const LocalChatMessage({
    required this.senderName,
    required this.time,
    required this.text,
    required this.isMine,
    required this.avatarPath,
    required this.initials,
    this.reaction,
    this.reactionCount,
    this.hasAttachment = false,
  });
}

class ChatRoomPage extends StatefulWidget {
  final AppUser currentUser;
  final ChatRoomEntity chatRoom;

  const ChatRoomPage({
    super.key,
    required this.currentUser,
    required this.chatRoom,
  });

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final TextEditingController inputController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  bool showAttachmentPanel = false;

  final List<LocalChatMessage> mockMessages = [
    const LocalChatMessage(
      senderName: 'Rahul Mehta',
      time: '10:30 AM',
      text: "Hey everyone !\nHow’s your sunday going?",
      isMine: false,
      avatarPath: 'assets/chat_assets/image 60.png',
      initials: 'RM',
      reaction: '👌',
      reactionCount: 4,
    ),
    const LocalChatMessage(
      senderName: 'Suhana',
      time: '9:30 AM',
      text: 'working on the assignment\nneed some help?!',
      isMine: false,
      avatarPath: 'assets/chat_assets/image 82.png',
      initials: 'SH',
    ),
    const LocalChatMessage(
      senderName: 'Swara',
      time: '2:00 AM',
      text: 'Try qlora\nits just tooo goood.',
      isMine: false,
      avatarPath: 'assets/chat_assets/image 60.png',
      initials: 'SW',
      reaction: '👍',
      reactionCount: 9,
    ),
    const LocalChatMessage(
      senderName: 'AKhil',
      time: '2:00 AM',
      text: 'You can also try Qlearn platform',
      isMine: true,
      avatarPath: 'assets/chat_assets/image 82.png',
      initials: 'AK',
      reaction: '👍',
      reactionCount: 9,
    ),
    const LocalChatMessage(
      senderName: 'Harika',
      time: '6:23 PM',
      text: 'Also check out this awsome resource',
      isMine: false,
      avatarPath: 'assets/chat_assets/image 60.png',
      initials: 'HK',
      hasAttachment: true,
    ),
    const LocalChatMessage(
      senderName: 'Suhana',
      time: '10:04 AM',
      text: 'Thanks\nit was super helpful!!!',
      isMine: false,
      avatarPath: 'assets/chat_assets/image 82.png',
      initials: 'SH',
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    inputController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final text = inputController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      final now = DateTime.now();
      final timeStr =
          "${now.hour % 12 == 0 ? 12 : now.hour % 12}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}";
      mockMessages.add(LocalChatMessage(
        senderName: widget.currentUser.name.isNotEmpty
            ? widget.currentUser.name
            : 'You',
        time: timeStr,
        text: text,
        isMine: true,
        avatarPath: 'assets/chat_assets/image 82.png',
        initials: 'ME',
      ));
      inputController.clear();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  Widget _buildCircularAvatar(String assetPath, String initials) {
    return ClipOval(
      child: Image.asset(
        assetPath,
        width: 38,
        height: 38,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return CircleAvatar(
            radius: 19,
            backgroundColor: const Color(0xFFECE7FF),
            child: Text(
              initials,
              style: const TextStyle(
                color: Color(0xFF6139ED),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResourceCard(bool isLightMode) {
    final cardBg = isLightMode ? Colors.white : const Color(0xFF2A2A2E);
    final borderColor =
        isLightMode ? const Color(0xFFE4E0F3) : const Color(0xFF3A3A42);
    final textColor = isLightMode ? const Color(0xFF1A1A1E) : Colors.white;
    final subTextColor =
        isLightMode ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF);

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        children: [
          // PDF Icon red block
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
                  "Fine - tuning LLM's\nA complete guide.",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'PDF',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: subTextColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 3,
                      height: 3,
                      decoration: BoxDecoration(
                        color: subTextColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '2.4 MB',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: subTextColor,
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

  Widget _buildMessageItem(LocalChatMessage msg, bool isLightMode) {
    final bubbleBg =
        isLightMode ? const Color(0xFFF5F2FD) : const Color(0xFF22202A);
    final textColor = isLightMode ? const Color(0xFF1E1E1E) : Colors.white;
    final timeColor =
        isLightMode ? const Color(0xFF8E8E93) : const Color(0xFF8E8E93);
    final senderColor = isLightMode ? Colors.black : Colors.white;

    final avatar = _buildCircularAvatar(msg.avatarPath, msg.initials);

    final chatBubble = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bubbleBg,
        borderRadius: BorderRadius.only(
          topLeft: msg.isMine ? const Radius.circular(16) : Radius.zero,
          topRight: msg.isMine ? Radius.zero : const Radius.circular(16),
          bottomLeft: const Radius.circular(16),
          bottomRight: const Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            msg.text,
            style: TextStyle(
              fontSize: 14,
              color: textColor,
              height: 1.4,
            ),
          ),
          if (msg.hasAttachment) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.auto_awesome,
                    color: const Color(0xFF6139ED).withValues(alpha: 0.4),
                    size: 14),
                const SizedBox(width: 4),
                Text(
                  '...',
                  style: TextStyle(color: timeColor, fontSize: 12),
                ),
              ],
            ),
            _buildResourceCard(isLightMode),
          ]
        ],
      ),
    );

    final List<Widget> columnChildren = [
      Row(
        mainAxisSize: MainAxisSize.min,
        children: msg.isMine
            ? [
                Text(
                  msg.time,
                  style: TextStyle(fontSize: 11, color: timeColor),
                ),
                const SizedBox(width: 8),
                Text(
                  msg.senderName,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: senderColor,
                  ),
                ),
              ]
            : [
                Text(
                  msg.senderName,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: senderColor,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  msg.time,
                  style: TextStyle(fontSize: 11, color: timeColor),
                ),
              ],
      ),
      const SizedBox(height: 6),
      Stack(
        clipBehavior: Clip.none,
        children: [
          chatBubble,
          if (msg.reaction != null)
            Positioned(
              bottom: -10,
              left: msg.isMine ? null : 16,
              right: msg.isMine ? 16 : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isLightMode ? Colors.white : const Color(0xFF2A2A2E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isLightMode
                        ? const Color(0xFFE4E0F3)
                        : const Color(0xFF3A3A42),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      msg.reaction!,
                      style: const TextStyle(fontSize: 10),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      msg.reactionCount!.toString(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isLightMode ? Colors.black54 : Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      if (msg.reaction != null) const SizedBox(height: 10),
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment:
            msg.isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: msg.isMine
            ? [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: columnChildren,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: columnChildren,
                  ),
                ),
              ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final LightModeController lightModeController =
        Get.find<LightModeController>();

    return Obx(() {
      final isLightMode = lightModeController.isLightMode.value;

      final backgroundColor =
          isLightMode ? Colors.white : const Color(0xFF121214);
      final textColor = isLightMode ? const Color(0xFF1A1A1E) : Colors.white;
      final subTextColor =
          isLightMode ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF);
      final cardColor = isLightMode ? Colors.white : const Color(0xFF1E1E22);
      final dividerColor =
          isLightMode ? const Color(0xFFEEEEEE) : const Color(0xFF2D2D33);

      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: AppBar(
            backgroundColor: cardColor,
            elevation: 0,
            automaticallyImplyLeading: false,
            shape: Border(bottom: BorderSide(color: dividerColor, width: 0.5)),
            title: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: textColor),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => Get.back(),
                ),
                const SizedBox(width: 8),
                // AI & ML Logo container
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/chat_assets/image 60.png',
                    width: 38,
                    height: 38,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 38,
                        height: 38,
                        color: const Color(0xFF6139ED),
                        child: const Center(
                          child: Text(
                            'AI',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'AI & ML Society',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            '3.4K Members',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: subTextColor,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              color: Color(0xFF00E676),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '243 Online',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: subTextColor,
                            ),
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
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.notifications_none, color: textColor);
                  },
                ),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
        body: Column(
          children: [
            // Messages Area
            Expanded(
              child: ListView(
                controller: scrollController,
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                children: [
                  // Today Divider Capsule
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isLightMode
                            ? const Color(0xFFF3F4F6)
                            : const Color(0xFF222226),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Today',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: subTextColor,
                        ),
                      ),
                    ),
                  ),

                  // Message cards list
                  ...mockMessages
                      .map((msg) => _buildMessageItem(msg, isLightMode)),

                  // Vicky is typing...
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCircularAvatar(
                            'assets/chat_assets/image 82.png', 'VK'),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Vicky',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isLightMode
                                    ? const Color(0xFFF5F2FD)
                                    : const Color(0xFF22202A),
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(16),
                                  bottomLeft: Radius.circular(16),
                                  bottomRight: Radius.circular(16),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Vicky is typing... ',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: subTextColor,
                                    ),
                                  ),
                                  const AnimatedTypingIndicator(),
                                ],
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

            // Bottom Input Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: cardColor,
                border:
                    Border(top: BorderSide(color: dividerColor, width: 0.5)),
              ),
              child: Row(
                children: [
                  // Plus Button wrapped in purple border circle
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
                        border: Border.all(
                            color: const Color(0xFF6139ED), width: 1.5),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Color(0xFF6139ED),
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Text input container
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: isLightMode
                            ? const Color(0xFFF5F2FD)
                            : const Color(0xFF22202A),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: inputController,
                              style: TextStyle(fontSize: 13, color: textColor),
                              decoration: InputDecoration(
                                hintText: 'Message in AI Ml Society....',
                                hintStyle: TextStyle(
                                  fontSize: 13,
                                  color: subTextColor.withValues(alpha: 0.8),
                                ),
                                border: InputBorder.none,
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: Image.asset(
                              'assets/chat_assets/Frame_Smilie.png',
                              width: 22,
                              height: 22,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(Icons.sentiment_satisfied_alt_outlined,
                                      color: subTextColor, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Mic / Voice Button
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: isLightMode
                            ? const Color(0xFFF5F2FD)
                            : const Color(0xFF22202A),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/chat_assets/Frame_microphone.png',
                          width: 20,
                          height: 20,
                          errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.mic_none_outlined,
                              color: subTextColor,
                              size: 20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (showAttachmentPanel)
              _buildAttachmentPanel(
                  isLightMode, textColor, subTextColor, cardColor),
          ],
        ),
      );
    });
  }

  Widget _buildAttachmentPanel(
      bool isLightMode, Color textColor, Color subTextColor, Color cardColor) {
    final panelBg = isLightMode ? Colors.white : const Color(0xFF1E1E22);
    final borderColor =
        isLightMode ? const Color(0xFFEEEEEE) : const Color(0xFF2D2D33);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: panelBg,
        border: Border(top: BorderSide(color: borderColor, width: 0.5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAttachmentOption(
                iconPath: 'assets/chat_assets/Frame.png',
                label: 'Photo',
                bgColor: isLightMode
                    ? const Color(0xFFF0ECFC)
                    : const Color(0xFF2D2545),
                textColor: textColor,
              ),
              _buildAttachmentOption(
                iconPath: 'assets/chat_assets/Frame_camera.png',
                label: 'Camera',
                bgColor: isLightMode
                    ? const Color(0xFFFDF2F8)
                    : const Color(0xFF452538),
                textColor: textColor,
              ),
              _buildAttachmentOption(
                iconPath: 'assets/chat_assets/Frame_file.png',
                label: 'File',
                bgColor: isLightMode
                    ? const Color(0xFFEFF6FF)
                    : const Color(0xFF253545),
                textColor: textColor,
              ),
              _buildAttachmentOption(
                iconPath: 'assets/chat_assets/Frame_document.png',
                label: 'Document',
                bgColor: isLightMode
                    ? const Color(0xFFECFDF5)
                    : const Color(0xFF224535),
                textColor: textColor,
              ),
              _buildAttachmentOption(
                iconPath: 'assets/chat_assets/Frame_Poll.png',
                label: 'poll',
                bgColor: isLightMode
                    ? const Color(0xFFFFF7ED)
                    : const Color(0xFF453525),
                textColor: textColor,
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Send File Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                // Mock sending a file message!
                setState(() {
                  showAttachmentPanel = false;
                  final now = DateTime.now();
                  final timeStr =
                      "${now.hour % 12 == 0 ? 12 : now.hour % 12}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}";
                  mockMessages.add(LocalChatMessage(
                    senderName: widget.currentUser.name.isNotEmpty
                        ? widget.currentUser.name
                        : 'You',
                    time: timeStr,
                    text: 'Shared a resource with the community',
                    isMine: true,
                    avatarPath: 'assets/chat_assets/image 82.png',
                    initials: 'ME',
                    hasAttachment: true,
                  ));
                });
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F1BE0),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Send File',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentOption({
    required String iconPath,
    required String label,
    required Color bgColor,
    required Color textColor,
  }) {
    return Column(
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
              color: const Color(0xFF6139ED),
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.insert_drive_file,
                    color: Color(0xFF6139ED));
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ],
    );
  }
}

class AnimatedTypingIndicator extends StatefulWidget {
  const AnimatedTypingIndicator({super.key});

  @override
  State<AnimatedTypingIndicator> createState() =>
      _AnimatedTypingIndicatorState();
}

class _AnimatedTypingIndicatorState extends State<AnimatedTypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final double delay = index * 0.2;
            final double value =
                (sin((_controller.value * 2 * pi) - delay) + 1) / 2;
            return Opacity(
              opacity: 0.3 + (value * 0.7),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  color: Color(0xFF6139ED),
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
