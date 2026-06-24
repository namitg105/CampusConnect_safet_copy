import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/message.dart';
import '../../domain/repos/chat_repo.dart';
import 'chat_states.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepo repo;

  StreamSubscription? _sub;

  ChatCubit(this.repo) : super(ChatInitial());

  void loadMessages(String groupId) {
    emit(ChatLoading());

    _sub?.cancel();

    _sub = repo.getMessages(groupId).listen(
      (messages) {
        emit(ChatLoaded(messages));
      },
      onError: (e) {
        emit(
          ChatError(
            e.toString(),
          ),
        );
      },
    );
  }

  Future<void> sendMessage({
    required String groupId,
    required String text,
  }) async {
    if (text.trim().isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;

    String senderName = "User";

    if (user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        senderName =
            userDoc.data()?['name'] ?? user.displayName ?? user.email ?? "User";
      } catch (_) {
        senderName = user.displayName ?? user.email ?? "User";
      }
    }

    await repo.sendMessage(
      groupId,
      Message(
        senderId: user?.uid ?? "",
        senderName: senderName,
        text: text.trim(),
        createdAt: Timestamp.now(),
      ),
    );
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
