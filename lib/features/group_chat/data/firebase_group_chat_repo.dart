import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/entities/group_chat.dart';
import '../domain/repo/group_chat_repo.dart';

class FirebaseGroupChatRepo implements GroupChatRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<GroupChat>> streamMessages(String groupId) {
    return _firestore
        .collection('group_chats')
        .where('groupId', isEqualTo: groupId)
        .orderBy('sentAt', descending: true) // Displays newest messages first
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return GroupChat.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  @override
  Future<void> sendMessage(GroupChat message) async {
    // Generates a clean document reference with a unique ID
    final docRef = _firestore.collection('group_chats').doc();

    // Updates the object with the auto-generated ID before saving
    final messageWithId = message.copyWith(id: docRef.id);

    await docRef.set(messageWithId.toMap());
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    await _firestore.collection('group_chats').doc(messageId).delete();
  }
}
