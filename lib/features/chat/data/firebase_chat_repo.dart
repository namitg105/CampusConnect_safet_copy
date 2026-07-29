import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:noteswap/features/events/notifications/services/notification_service.dart';
import 'package:noteswap/features/events/notifications/models/notification_model.dart';
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

    // Send Notification to group members
    try {
      final senderName = userDoc.data()?['name'] ?? 'Someone';
      final groupDoc = await firestore.collection('groups').doc(groupId).get();
      final groupName = groupDoc.data()?['name'] ?? 'Community';
      
      final membersSnapshot = await firestore
          .collection('groups')
          .doc(groupId)
          .collection('members')
          .get();
          
      for (var memberDoc in membersSnapshot.docs) {
        final recipientId = memberDoc.id;
        if (recipientId != message.senderId) {
          await NotificationService.createNotification(
            recipientId: recipientId,
            type: NotificationType.requestChatGroup,
            title: '$groupName: New message',
            description: '$senderName: ${message.text}',
            subtitle: groupId,
          );
        }
      }
    } catch (e) {
      print("Failed to send group message notification: $e");
    }
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
