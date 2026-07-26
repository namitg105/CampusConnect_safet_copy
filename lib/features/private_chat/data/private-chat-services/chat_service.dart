import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:noteswap/features/private_chat/data/private-chat-storage-service/storage_service.dart';
import 'package:noteswap/features/private_chat/domain/entities/pinned_message.dart';
import '../../domain/entities/chat_message.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _pinnedDocId = 'current_pinned';
  final StorageService _storageService = StorageService();

  String _generateRoomId(String uid1, String uid2) {
    List<String> ids = [uid1, uid2];
    ids.sort();
    return ids.join('_');
  }

  /*
  Future<String> createChatRoom(String uid1, String uid2) async {
    String roomId = _generateRoomId(uid1, uid2);
    DocumentReference roomRef = _firestore.collection('chat_rooms').doc(roomId);

    bool exists = (await roomRef.get()).exists;
    if (!exists) {
      await roomRef.set({
        'participants': [uid1, uid2],
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessage': '',
        'lastMessageTimestamp': FieldValue.serverTimestamp(),
      });
    }

    return roomId;
  }
  */

  Future<String> createChatRoom(String uid1, String uid2) async {
    String roomId = _generateRoomId(uid1, uid2);
    DocumentReference roomRef = _firestore.collection('chat_rooms').doc(roomId);

    bool exists = (await roomRef.get()).exists;
    if (!exists) {
      // 1. Create the parent chat room document
      await roomRef.set({
        'participants': [uid1, uid2],
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessage': '',
        'lastMessageTimestamp': FieldValue.serverTimestamp(),
      });

      // 2. SATISFIED: Explicitly initialize the pinned_message subcollection
      // with an empty placeholder document right at creation time.
      await roomRef.collection('pinned_message').doc(_pinnedDocId).set({
        'pinned_message_id': '',
        'pinned_message_content': '',
        'pinned_by': '',
        'pinned_message_timestamp': FieldValue.serverTimestamp(),
      });
    }

    return roomId;
  }

  Future<void> sendMessage({
    required String roomId,
    required String senderId,
    required String receiverId,
    required String message,
    MessageType type = MessageType.text,
    String? imageUrl,
    String? docUrl,
    String? repliedMessageId,
    String? repliedMessageContent,
    String? repliedMessageSender,
    String? repliedMessageType,
    bool skipUnreadIncrement = false,
  }) async {
    await _firestore
        .collection('chat_rooms')
        .doc(roomId)
        .collection('messages')
        .add({
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
      'type': type.name,
      'imageUrl': imageUrl,
      'docUrl': docUrl,
      'repliedMessageId': repliedMessageId,
      'repliedMessageContent': repliedMessageContent,
      'repliedMessageSender': repliedMessageSender,
      'repliedMessageType': repliedMessageType,
    });

    String summary = message;
    if (type == MessageType.image) summary = "📷 Photo";
    if (type == MessageType.doc) summary = "📄 $message";
    if (repliedMessageId != null) {
      summary = '↪ $summary';
    }

    final roomUpdate = <String, dynamic>{
      'lastMessage': summary,
      'lastMessageTimestamp': FieldValue.serverTimestamp(),
    };

    if (!skipUnreadIncrement) {
      roomUpdate['unreadCount_$receiverId'] = FieldValue.increment(1);
    }

    await _firestore.collection('chat_rooms').doc(roomId).update(roomUpdate);
  }

  // Add this method inside your ChatService class
  Stream<List<Map<String, dynamic>>> getUsersDirectory(String currentUid) {
    return _firestore
        .collection('users')
        .where('uid', isNotEqualTo: currentUid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  Stream<List<ChatMessage>> getMessages(String roomId) {
    return _firestore
        .collection('chat_rooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ChatMessage.fromJson(doc.data(), doc.id);
      }).toList();
    });
  }

  Stream<List<Map<String, dynamic>>> getUserChatRooms(String uid) {
    return _firestore
        .collection('chat_rooms')
        .where('participants', arrayContains: uid)
        //.orderBy('lastMessageTimestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data()};
      }).toList();
    });
  }

  Future<String> getOrCreateChatRoom(String uid1, String uid2) async {
    return await createChatRoom(uid1, uid2);
  }

  Future<Map<String, dynamic>> getRoomInfo(
      String roomId, String currentUid) async {
    final doc = await _firestore.collection('chat_rooms').doc(roomId).get();
    if (!doc.exists) throw Exception('Room not found');

    final data = doc.data()!;
    final participants = List<String>.from(data['participants'] ?? []);
    final otherUid = participants.firstWhere((id) => id != currentUid);

    final userDoc = await _firestore.collection('users').doc(otherUid).get();
    final userName = userDoc.data()?['name'] ?? 'Unknown';

    return {
      'createdAt': data['createdAt'],
      'participantName': userName,
      'lastMessage': data['lastMessage'] ?? '',
    };
  }

  Stream<Map<String, dynamic>> getRoomInfoStream(
      String roomId, String currentUid) {
    return _firestore
        .collection('chat_rooms')
        .doc(roomId)
        .snapshots()
        .asyncMap((docSnapshot) async {
      if (!docSnapshot.exists) throw Exception('Room not found');

      final data = docSnapshot.data()!;
      final participants = List<String>.from(data['participants'] ?? []);
      final otherUid = participants.firstWhere((id) => id != currentUid);

      final userDoc = await _firestore.collection('users').doc(otherUid).get();
      final userName = userDoc.data()?['name'] ?? 'Unknown';

      return {
        'createdAt': data['createdAt'],
        'participantName': userName,
        'lastMessage': data['lastMessage'] ?? '',
      };
    });
  }

  Future<void> markMessagesAsRead(String roomId, String uid) async {
    QuerySnapshot snapshot = await _firestore
        .collection('chat_rooms')
        .doc(roomId)
        .collection('messages')
        .where('receiverId', isEqualTo: uid)
        .where('read', isEqualTo: false)
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.update({'read': true});
    }

    await _firestore.collection('chat_rooms').doc(roomId).update({
      'unreadCount_$uid': 0,
    });
  }

  Future<void> toggleReaction({
    required String roomId,
    required String messageId,
    required String userId,
    required String emoji,
  }) async {
    final docRef = _firestore
        .collection('chat_rooms')
        .doc(roomId)
        .collection('messages')
        .doc(messageId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;
      final data = snapshot.data() as Map<String, dynamic>;
      final reactions = Map<String, dynamic>.from(data['reactions'] as Map? ?? {});
      final currentEmoji = reactions[userId] as String?;

      if (currentEmoji == emoji) {
        transaction.update(docRef, {
          'reactions.$userId': FieldValue.delete(),
        });
      } else {
        transaction.update(docRef, {
          'reactions.$userId': emoji,
        });
      }
    });
  }

  Future<void> deleteMessage({
    required String roomId,
    required String messageId,
    required String currentUid,
  }) async {
    // 1. Fetch current user profile to grab their name string
    final userDoc = await _firestore.collection('users').doc(currentUid).get();
    final String userName = userDoc.data()?['name'] ?? 'Someone';

    // 2. Overwrite only the target fields inside the message document
    await _firestore
        .collection('chat_rooms')
        .doc(roomId)
        .collection('messages')
        .doc(messageId)
        .update({
      'message': 'Deleted by $userName',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<List<String>> getAllImages(String roomId) async {
    try {
      final querySnapshot = await _firestore
          .collection('chat_rooms')
          .doc(roomId)
          .collection('messages')
          .where('type',
              isEqualTo:
                  'image') //.orderBy('timestamp', descending: true) // Newest media first
          .get();

      // Extract raw non-null imageUrl values safely
      List<String> imageUrls = querySnapshot.docs
          .map((doc) => doc.data()['imageUrl'] as String?)
          .where((url) => url != null && url.isNotEmpty)
          .cast<String>()
          .toList();

      return imageUrls;
    } catch (e) {
      print("Error fetching chat images collection: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAllDocs(String roomId) async {
    try {
      final querySnapshot = await _firestore
          .collection('chat_rooms')
          .doc(roomId)
          .collection('messages')
          .where('type', isEqualTo: 'doc')
          .get();

      List<Map<String, dynamic>> docs = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'url': data['docUrl'] as String? ?? '',
          'name': data['message'] as String? ?? 'Unknown file',
          'timestamp': (data['timestamp'] as dynamic)?.toDate() ?? DateTime.now(),
        };
      }).where((d) => (d['url'] as String).isNotEmpty).toList();

      return docs;
    } catch (e) {
      print("Error fetching chat documents collection: $e");
      return [];
    }
  }

  Stream<PinnedMessage?> getPinnedCollection(String chatRoomId) {
    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('pinned_message')
        .doc(_pinnedDocId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return null;
      return PinnedMessage.fromJson(snapshot.data()!);
    });
  }

  String getPinnedMessage(PinnedMessage pinned) => pinned.pinnedMessageContent;
  String getPinnedBy(PinnedMessage pinned) => pinned.pinnedBy;
  DateTime getPinnedMessageTime(PinnedMessage pinned) =>
      pinned.pinnedMessageTimestamp;

  Future<void> setPinnedMessage(
      String roomId, ChatMessage message, String pinnedByUid) async {
    final pinnedData = PinnedMessage(
      pinnedMessageTimestamp:
          DateTime.now(), // Fallback (rules use server timestamp)
      pinnedMessageId: message.messageId,
      pinnedMessageContent: message.message,
      pinnedBy: pinnedByUid,
    );

    await _firestore
        .collection('chat_rooms')
        .doc(roomId)
        .collection('pinned_message')
        .doc(_pinnedDocId)
        .set(pinnedData.toJson(), SetOptions(merge: true));
  }

  Future<void> deletePinnedMessage(String roomId) async {
    await _firestore
        .collection('chat_rooms')
        .doc(roomId)
        .collection('pinned_message')
        .doc(_pinnedDocId)
        .delete();
  }

  /*
  Future<void> deleteMessageAndUpdateType({
    required String roomId,
    required String messageId,
    required String currentUid,
    String? imageUrlToClean,
    String? docUrlToClean,
  }) async {
    // 1. If an image url is linked, remove it from Firebase Storage
    if (imageUrlToClean != null && imageUrlToClean.isNotEmpty) {
      await _storageService.deleteStorageFileByUrl(imageUrlToClean);
    }
    if (docUrlToClean != null && docUrlToClean.isNotEmpty) {
      await _storageService.deleteStorageFileByUrl(docUrlToClean);
    }

    // 2. Fetch current profile name
    final userDoc = await _firestore.collection('users').doc(currentUid).get();
    final String userName = userDoc.data()?['name'] ?? 'Someone';

    // 3. Overwrite message parameters, clearing out the imageUrl and converting the type to text
    await _firestore
        .collection('chat_rooms')
        .doc(roomId)
        .collection('messages')
        .doc(messageId)
        .update({
      'message': 'Deleted by $userName',
      'type': 'text', // Reset type to text
      'imageUrl': null, // Erase media URL field reference
      'docUrl': null,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
  */
  Future<void> deleteMessageAndUpdateType({
    required String roomId,
    required String messageId,
    required String currentUid,
    String? imageUrlToClean,
    String? docUrlToClean, // Added parameter
  }) async {
    // 1. Clean up from Storage if assets exist
    if (imageUrlToClean != null && imageUrlToClean.isNotEmpty) {
      await _storageService.deleteStorageFileByUrl(imageUrlToClean);
    }
    if (docUrlToClean != null && docUrlToClean.isNotEmpty) {
      await _storageService.deleteStorageFileByUrl(docUrlToClean);
    }

    // 2. Fetch current profile name
    final userDoc = await _firestore.collection('users').doc(currentUid).get();
    final String userName = userDoc.data()?['name'] ?? 'Someone';

    // 3. Overwrite message parameters completely resetting types
    await _firestore
        .collection('chat_rooms')
        .doc(roomId)
        .collection('messages')
        .doc(messageId)
        .update({
      'message': 'Deleted by $userName',
      'type': 'text',
      'imageUrl': null,
      'docUrl': null, // Erase file link reference on delete
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
