import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/entities/message.dart';
import '../domain/repos/chat_repo.dart';

class FirebaseChatRepo implements ChatRepo {
  final FirebaseFirestore firestore;

  FirebaseChatRepo(this.firestore);

  @override
  Stream<List<Message>> getMessages(String groupId) {
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
          (snapshot) => snapshot.docs
              .map(
                (doc) => Message.fromDocument(doc),
              )
              .toList(),
        );
  }

  @override
  Future<void> sendMessage(String groupId, Message message) async {
    final userDoc = await firestore
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    print(userDoc.data());
    print("Sender Image: ${userDoc["profileImage"]}");
    final data = message.toMap();
    data["senderImage"] = userDoc["profileImage"];

    await firestore
        .collection("chats")
        .doc(groupId)
        .collection("messages")
        .add(data);
  }

  @override
  Future<void> deleteMessage({
    required String groupId,
    required String messageId,
  }) async {
    await firestore
        .collection('chats')
        .doc(groupId)
        .collection('messages')
        .doc(messageId)
        .delete();
  }

  Future<void> updateMessage({
    required String groupId,
    required String messageId,
    required String text,
  }) async {
    final encryptedText = Message(
      id: '',
      senderId: '',
      senderName: '',
      senderImage: null,
      text: text,
      type: 'text',
      mediaUrl: null,
      createdAt: Timestamp.now(),
    ).toMap()['text'];
    await firestore
        .collection('chats')
        .doc(groupId)
        .collection('messages')
        .doc(messageId)
        .update({
      'text': encryptedText,
    });
  }
}
