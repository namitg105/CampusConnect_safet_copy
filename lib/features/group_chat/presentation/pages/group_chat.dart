import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/group_chat.dart';
import 'group_profile.dart';

class ChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  const ChatPage({super.key, required this.groupId, required this.groupName});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final String uid = FirebaseAuth.instance.currentUser?.uid ?? "";
  final String uName = FirebaseAuth.instance.currentUser?.displayName ?? "You";

  static const Color primary = Color(0xFF6366F1);
  static const Color dark = Color(0xFF0F172A);
  static const Color muted = Color(0xFF64748B);

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _send() async {
    if (_msgCtrl.text.trim().isEmpty || uid.isEmpty) return;
    final text = _msgCtrl.text.trim();
    _msgCtrl.clear();

    final doc = FirebaseFirestore.instance
        .collection('group_chats')
        .doc(widget.groupId)
        .collection('messages')
        .doc();

    await doc.set(GroupChat(
      id: doc.id,
      groupId: widget.groupId,
      senderId: uid,
      senderName: uName,
      senderImageUrl: FirebaseAuth.instance.currentUser?.photoURL ?? "",
      message: text,
      messageType: "text",
      sentAt: Timestamp.now(),
    ).toMap());

    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _deleteMessage(String messageId) async {
    try {
      await FirebaseFirestore.instance
          .collection('group_chats')
          .doc(widget.groupId)
          .collection('messages')
          .doc(messageId)
          .delete();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete message: $e")),
        );
      }
    }
  }

  // --- NEW: Pin Message Functionality ---
  void _pinMessage(GroupChat chat) async {
    try {
      await FirebaseFirestore.instance
          .collection('group_chats')
          .doc(widget.groupId)
          .update({
        'pinnedMessage': {
          'id': chat.id,
          'text': chat.message,
          'senderName': chat.senderName,
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to pin message: $e")),
        );
      }
    }
  }

  // --- NEW: Unpin Message Functionality ---
  void _unpinMessage() async {
    try {
      await FirebaseFirestore.instance
          .collection('group_chats')
          .doc(widget.groupId)
          .update({'pinnedMessage': FieldValue.delete()});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to unpin message: $e")),
        );
      }
    }
  }

  void _showOptions(BuildContext context, GroupChat chat, bool isMe) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Pin action available to everyone (or add role checks if required)
            ListTile(
              leading: const Icon(Icons.pin_drop_rounded, color: primary),
              title: const Text(
                "Pin Message",
                style: TextStyle(color: dark, fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _pinMessage(chat);
              },
            ),
            if (isMe) ...[
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded,
                    color: Colors.redAccent),
                title: const Text(
                  "Delete Message",
                  style: TextStyle(
                      color: Colors.redAccent, fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _deleteMessage(chat.id);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(74),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: AppBar(
              backgroundColor: Colors.white.withOpacity(0.85),
              elevation: 0,
              automaticallyImplyLeading: false,
              leading: Center(
                child: Container(
                  margin: const EdgeInsets.only(left: 12),
                  decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: dark, size: 18),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              titleSpacing: 12,
              title: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: primary.withOpacity(0.08),
                    child: const Icon(Icons.bubble_chart_rounded,
                        color: primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(widget.groupName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: dark,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                letterSpacing: -0.3)),
                        const SizedBox(height: 2),
                        const Text("Active Space",
                            style: TextStyle(
                                color: Color(0xFF22C55E),
                                fontWeight: FontWeight.w600,
                                fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.info_outline_rounded,
                      color: dark, size: 22),
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              GroupDetailsPage(groupId: widget.groupId))),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('group_chats')
                        .doc(widget.groupId)
                        .collection('messages')
                        .orderBy('sentAt', descending: false)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator(color: primary));
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.forum_outlined,
                                  size: 48, color: Colors.grey[300]),
                              const SizedBox(height: 12),
                              const Text(
                                  "No messages yet. Start the conversation!",
                                  style: TextStyle(
                                      color: muted,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        );
                      }

                      final docs = snapshot.data!.docs;

                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (_scrollCtrl.hasClients) {
                          _scrollCtrl
                              .jumpTo(_scrollCtrl.position.maxScrollExtent);
                        }
                      });

                      return ListView.builder(
                        controller: _scrollCtrl,
                        reverse: false,
                        // Increased top padding slightly to make visual breathing room for the header
                        padding: const EdgeInsets.fromLTRB(20, 165, 20, 20),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final chat = GroupChat.fromMap(docs[index].id,
                              docs[index].data() as Map<String, dynamic>);
                          final bool isMe = chat.senderId == uid;
                          final String time = DateFormat('h:mm a').format(
                              (chat.sentAt ?? Timestamp.now()).toDate());

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              mainAxisAlignment: isMe
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (!isMe) ...[
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: const Color(0xFFE2E8F0),
                                    child: chat.senderImageUrl.trim().isEmpty
                                        ? Text(
                                            chat.senderName.characters.first
                                                .toUpperCase(),
                                            style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: muted))
                                        : ClipOval(
                                            child: Image.network(
                                                chat.senderImageUrl,
                                                fit: BoxFit.cover)),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment: isMe
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 6, right: 6, bottom: 4),
                                        child: Text(
                                            isMe ? "You" : chat.senderName,
                                            style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: muted)),
                                      ),
                                      GestureDetector(
                                        onLongPress: () =>
                                            _showOptions(context, chat, isMe),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 12),
                                          decoration: BoxDecoration(
                                            color: isMe
                                                ? primary
                                                : const Color(0xFFF1F5F9),
                                            borderRadius: BorderRadius.only(
                                              topLeft:
                                                  const Radius.circular(20),
                                              topRight:
                                                  const Radius.circular(20),
                                              bottomLeft: isMe
                                                  ? const Radius.circular(20)
                                                  : const Radius.circular(4),
                                              bottomRight: isMe
                                                  ? const Radius.circular(4)
                                                  : const Radius.circular(20),
                                            ),
                                          ),
                                          child: Text(chat.message,
                                              style: TextStyle(
                                                  color: isMe
                                                      ? Colors.white
                                                      : dark,
                                                  fontSize: 14.5,
                                                  fontWeight: FontWeight.w500,
                                                  height: 1.35)),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 4, left: 6, right: 6),
                                        child: Text(time,
                                            style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w400,
                                                color: Color(0xFF94A3B8))),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                                color: dark.withOpacity(0.04),
                                blurRadius: 20,
                                offset: const Offset(0, -4))
                          ]),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(18)),
                            child: IconButton(
                              icon: const Icon(Icons.add_rounded,
                                  color: muted, size: 24),
                              onPressed: () => showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.white,
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(28))),
                                builder: (ctx) => SafeArea(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                            width: 38,
                                            height: 4,
                                            decoration: BoxDecoration(
                                                color: const Color(0xFFE2E8F0),
                                                borderRadius:
                                                    BorderRadius.circular(2))),
                                        const SizedBox(height: 24),
                                        GridView.count(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          crossAxisCount: 4,
                                          mainAxisSpacing: 20,
                                          crossAxisSpacing: 16,
                                          children: [
                                            {
                                              "icon": Icons.image_rounded,
                                              "label": "Gallery",
                                              "color": const Color(0xFF3B82F6)
                                            },
                                            {
                                              "icon": Icons.description_rounded,
                                              "label": "Document",
                                              "color": const Color(0xFFEF4444)
                                            },
                                            {
                                              "icon": Icons.location_on_rounded,
                                              "label": "Location",
                                              "color": const Color(0xFF10B981)
                                            },
                                            {
                                              "icon": Icons.headset_rounded,
                                              "label": "Audio",
                                              "color": const Color(0xFF8B5CF6)
                                            },
                                          ]
                                              .map((item) => GestureDetector(
                                                    onTap: () =>
                                                        Navigator.pop(ctx),
                                                    child: Column(
                                                      children: [
                                                        Container(
                                                          height: 54,
                                                          width: 54,
                                                          decoration: BoxDecoration(
                                                              color: (item[
                                                                          "color"]
                                                                      as Color)
                                                                  .withOpacity(
                                                                      0.08),
                                                              shape: BoxShape
                                                                  .circle),
                                                          child: Icon(
                                                              item["icon"]
                                                                  as IconData,
                                                              color:
                                                                  item["color"]
                                                                      as Color,
                                                              size: 24),
                                                        ),
                                                        const SizedBox(
                                                            height: 8),
                                                        Text(
                                                            item["label"]
                                                                as String,
                                                            style: const TextStyle(
                                                                color: dark,
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600)),
                                                      ],
                                                    ),
                                                  ))
                                              .toList(),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _msgCtrl,
                              maxLines: 4,
                              minLines: 1,
                              style: const TextStyle(
                                  color: dark,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500),
                              decoration: const InputDecoration(
                                  hintText: "Type a message...",
                                  hintStyle: TextStyle(
                                      color: Color(0xFF94A3B8), fontSize: 14),
                                  border: InputBorder.none,
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 10)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                                color: primary,
                                borderRadius: BorderRadius.circular(18)),
                            child: IconButton(
                                icon: const Icon(Icons.send_rounded,
                                    color: Colors.white, size: 18),
                                onPressed: _send),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // --- NEW: Live Pinned Message Header Banner ---
            Positioned(
              top:
                  100, // Positions it cleanly below your 74px blur custom app bar
              left: 16,
              right: 16,
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('group_chats')
                    .doc(widget.groupId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const SizedBox.shrink();
                  }

                  final data = snapshot.data!.data() as Map<String, dynamic>?;
                  final pinned =
                      data?['pinnedMessage'] as Map<String, dynamic>?;

                  if (pinned == null) return const SizedBox.shrink();

                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: primary.withOpacity(0.15), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: dark.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.pin_drop_rounded,
                            color: primary, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Pinned by ${pinned['senderName'] ?? 'Member'}",
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: primary,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                pinned['text'] ?? "",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: dark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.close_rounded,
                              color: muted, size: 18),
                          onPressed: _unpinMessage,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
