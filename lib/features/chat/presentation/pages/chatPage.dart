import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../community/data/firebase_group_repo.dart';
import '../../Widgets/chatPage.dart';
import '../cubits/chat_cubit.dart';

class ChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;

  const ChatPage({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController controller = TextEditingController();
  final ScrollController scrollController = ScrollController();

  String groupImage = "";
  String adminId = "";

  @override
  void initState() {
    super.initState();
    context.read<ChatCubit>().loadMessages(widget.groupId);
    loadGroupImage();
  }

  Future<void> loadGroupImage() async {
    final doc = await FirebaseFirestore.instance
        .collection("groups")
        .doc(widget.groupId)
        .get();

    if (doc.exists && mounted) {
      final data = doc.data();

      setState(() {
        groupImage = data?["imageUrl"] ?? "";
        adminId = (data?["adminId"] ??
                data?["creatorUid"] ??
                data?["createdBy"] ??
                data?["uid"] ??
                "")
            .toString();
      });
    }
  }

  Future<void> leaveGroup() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await sl<FirebaseGroupRepo>().leaveGroup(widget.groupId, uid);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Left group successfully"),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to leave group: $e"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> showLeaveDialog() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Leave Group",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1E),
          ),
        ),
        content: const Text(
          "Are you sure you want to leave this group?",
          style: TextStyle(color: Color(0xFF6B7280), fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              "Cancel",
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Leave",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await leaveGroup();
    }
  }

  Future<void> _sendMessage() async {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    await context.read<ChatCubit>().sendMessage(
          groupId: widget.groupId,
          text: text,
        );

    controller.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.read<ChatCubit>().currentUserId;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: ChatAppBar(
        groupId: widget.groupId,
        groupName: widget.groupName,
        groupImage: groupImage,
        onLeave: showLeaveDialog,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            Expanded(
              child: ChatMessageList(
                groupId: widget.groupId,
                scrollController: scrollController,
                adminId: adminId,
                currentUserId: currentUserId,
              ),
            ),
            ChatInputBar(
              controller: controller,
              onSend: _sendMessage,
              onPickImage: () =>
                  context.read<ChatCubit>().sendImage(widget.groupId),
              onPickVideo: () =>
                  context.read<ChatCubit>().sendVideo(widget.groupId),
              onPickDocument: () =>
                  context.read<ChatCubit>().sendDocument(widget.groupId),
            ),
          ],
        ),
      ),
    );
  }
}
