import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/entities/message.dart';
import '../domain/repos/chat_repo.dart';

class FirebaseChatRepo implements ChatRepo {
  final FirebaseFirestore firestore;

  FirebaseChatRepo(
    this.firestore,
  );

  @override
  Stream<List<Message>> getMessages(
    String groupId,
  ) {
    return firestore
        .collection('chats')
        .doc(groupId)
        .collection('messages')
        .orderBy(
          'createdAt',
          descending: false,
        )
        .snapshots()
        .map(
      (snapshot) {
        return snapshot.docs
            .map(
              (e) => Message.fromMap(
                e.data(),
              ),
            )
            .toList();
      },
    );
  }

  @override
  Future<void> sendMessage(
    String groupId,
    Message message,
  ) async {
    await firestore.collection('chats').doc(groupId).collection('messages').add(
          message.toMap(),
        );
  }
}
