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

    if (doc.exists) {
      setState(() {
        groupImage = doc.data()?["imageUrl"] ?? "";
      });
    }
  }

  Future<void> leaveGroup() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      await sl<FirebaseGroupRepo>().leaveGroup(
        widget.groupId,
        uid,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Left group successfully"),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to leave group: $e"),
        ),
      );
    }
  }

  Future<void> showLeaveDialog() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Leave Group"),
        content: const Text(
          "Are you sure you want to leave this group?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Leave"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await leaveGroup();
    }
  }

  Future<void> _sendMessage() async {
    if (controller.text.trim().isEmpty) return;

    await context.read<ChatCubit>().sendMessage(
          groupId: widget.groupId,
          text: controller.text,
        );

    controller.clear();

    Future.delayed(
      const Duration(milliseconds: 200),
      () {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ChatAppBar(
        groupId: widget.groupId,
        groupName: widget.groupName,
        groupImage: groupImage,
        onLeave: showLeaveDialog,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ChatMessageList(
                groupId: widget.groupId,
                scrollController: scrollController,
              ),
            ),
            ChatInputBar(
              controller: controller,
              onSend: _sendMessage,
              onPickImage: () {
                context.read<ChatCubit>().sendImage(widget.groupId);
              },
              onPickVideo: () {
                context.read<ChatCubit>().sendVideo(widget.groupId);
              },
              onPickDocument: () {
                context.read<ChatCubit>().sendDocument(widget.groupId);
              },
            ),
          ],
        ),
      ),
    );
  }
}
