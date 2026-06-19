import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/message.dart';
import '../cubits/chat_cubit.dart';
import '../cubits/chat_states.dart';
import '../components/message_bubble.dart';
import '../../../../core/di/injection.dart';
import '../../domain/repos/chat_repo.dart';

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
  final controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    context.read<ChatCubit>().loadMessages(
          widget.groupId,
        );
  }

  Future<void> sendMessage() async {
    if (controller.text.isEmpty) return;

    await sl<ChatRepo>().sendMessage(
      widget.groupId,
      Message(
        senderId: "uid",
        senderName: "User",
        text: controller.text,
        createdAt: Timestamp.now(),
      ),
    );

    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatCubit, ChatState>(
              builder: (context, state) {
                if (state is ChatLoaded) {
                  return ListView(
                    children: state.messages
                        .map(
                          (msg) => MessageBubble(
                            sender: msg.senderName,
                            message: msg.text,
                          ),
                        )
                        .toList(),
                  );
                }

                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                  ),
                ),
                IconButton(
                  onPressed: sendMessage,
                  icon: const Icon(
                    Icons.send,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
