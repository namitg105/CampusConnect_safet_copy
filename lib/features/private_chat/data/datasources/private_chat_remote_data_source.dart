import 'dart:io';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/error/exceptions.dart';
import '../../../events/notifications/models/notification_model.dart';
import '../../../events/notifications/services/notification_service.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chat_room.dart';
import '../../domain/repositories/private_chat_repository.dart';
import '../models/private_chat_models.dart';

abstract interface class PrivateChatRemoteDataSource {
  Stream<List<ChatRoomModel>> watchChatRooms(String uid);
  Future<String> getOrCreateRoom(String uid1, String uid2);
  Stream<List<ChatMessageModel>> watchMessages(String roomId);
  Stream<PinnedMessageModel?> watchPinned(String roomId);
  Stream<bool> watchUserOnline(String uid);
  Future<void> markAsRead(String roomId, String uid);
  Future<String> uploadAttachment(
      LocalAttachment file, MessageType type, String senderUid);
  Future<void> sendMessage(OutgoingMessage message,
      {String? imageUrl, String? docUrl});
  Future<void> toggleReaction({
    required String roomId,
    required String messageId,
    required String userId,
    required String emoji,
  });
  Future<void> deleteMessage(
      String roomId, ChatMessage message, String currentUid);
  Future<void> pinMessage(String roomId, ChatMessage message, String byUid);
  Future<void> unpinMessage(String roomId);
  Future<RoomDetails> getRoomDetails(String roomId, String currentUid);
  Future<List<String>> getSharedImages(String roomId);
  Future<List<SharedFile>> getSharedDocuments(String roomId);
  Future<String?> getPhoneNumber(String uid);
}

class PrivateChatRemoteDataSourceImpl implements PrivateChatRemoteDataSource {
  static const _pinnedDocId = 'current_pinned';

  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  const PrivateChatRemoteDataSourceImpl({
    required this.firestore,
    required this.storage,
  });

  CollectionReference<Map<String, dynamic>> get _rooms =>
      firestore.collection('chat_rooms');

  CollectionReference<Map<String, dynamic>> _messages(String roomId) =>
      _rooms.doc(roomId).collection('messages');

  DocumentReference<Map<String, dynamic>> _pin(String roomId) =>
      _rooms.doc(roomId).collection('pinned_message').doc(_pinnedDocId);

  Future<String> _userName(String uid, {String fallback = 'Someone'}) async {
    final doc = await firestore.collection('users').doc(uid).get();
    return doc.data()?['name'] ?? fallback;
  }

  @override
  Stream<List<ChatRoomModel>> watchChatRooms(String uid) {
    return _rooms.where('participants', arrayContains: uid).snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => ChatRoomModel.fromJson(doc.id, doc.data()))
            .toList());
  }

  @override
  Future<String> getOrCreateRoom(String uid1, String uid2) async {
    final roomId = ChatRoomSummary.idFor(uid1, uid2);
    final roomRef = _rooms.doc(roomId);
    if (!(await roomRef.get()).exists) {
      await roomRef.set({
        'participants': [uid1, uid2],
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessage': '',
        'lastMessageTimestamp': FieldValue.serverTimestamp(),
      });
      // Every room starts with an empty pin placeholder.
      await _pin(roomId).set({
        'pinned_message_id': '',
        'pinned_message_content': '',
        'pinned_by': '',
        'pinned_message_timestamp': FieldValue.serverTimestamp(),
      });
    }
    return roomId;
  }

  @override
  Stream<List<ChatMessageModel>> watchMessages(String roomId) {
    return _messages(roomId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessageModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  @override
  Stream<PinnedMessageModel?> watchPinned(String roomId) {
    return _pin(roomId).snapshots().map((snapshot) {
      final data = snapshot.data();
      if (!snapshot.exists || data == null) return null;
      return PinnedMessageModel.fromJson(data);
    });
  }

  @override
  Stream<bool> watchUserOnline(String uid) {
    return firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .where((snapshot) => snapshot.exists && snapshot.data() != null)
        .map((snapshot) => snapshot.data()!['isOnline'] ?? false);
  }

  @override
  Future<void> markAsRead(String roomId, String uid) async {
    final unread = await _messages(roomId)
        .where('receiverId', isEqualTo: uid)
        .where('read', isEqualTo: false)
        .get();
    // Batched writes instead of one round trip per message. A batch holds
    // at most 500 writes, so large backlogs are split.
    const chunk = 400;
    final docs = unread.docs;
    for (var i = 0; i < docs.length; i += chunk) {
      final batch = firestore.batch();
      for (final doc in docs.skip(i).take(chunk)) {
        batch.update(doc.reference, {'read': true});
      }
      await batch.commit();
    }
    await _rooms.doc(roomId).update({'unreadCount_$uid': 0});
  }

  /// Files are named by position in the sender's folder (1.jpg, 2.jpg …),
  /// falling back to a timestamp when the folder cannot be listed.
  @override
  Future<String> uploadAttachment(
      LocalAttachment file, MessageType type, String senderUid) async {
    final isImage = type == MessageType.image;
    final folderRef = storage.ref().child(isImage
        ? 'private_chat/images/images_$senderUid'
        : 'private_chat/documents/doc_$senderUid');

    int nextIndex;
    try {
      nextIndex = (await folderRef.listAll()).items.length + 1;
    } catch (_) {
      nextIndex = DateTime.now().millisecondsSinceEpoch;
    }
    final extension = file.name.split('.').last.toLowerCase();
    final fileName = '$nextIndex.$extension';
    final localFile = File(file.path);

    final SettableMetadata metadata;
    if (isImage) {
      final image = await _decode(await localFile.readAsBytes());
      metadata = SettableMetadata(
        contentType: 'image/$extension',
        customMetadata: {
          'imageName': fileName,
          'imageOwner': senderUid,
          'timestamp': DateTime.now().toIso8601String(),
          'width': image.width.toString(),
          'height': image.height.toString(),
          'format': extension,
        },
      );
    } else {
      metadata = SettableMetadata(
        contentType: 'application/$extension',
        customMetadata: {
          'documentName': fileName,
          'documentOwner': senderUid,
          'timestamp': DateTime.now().toIso8601String(),
          'format': extension,
        },
      );
    }

    final snapshot =
        await folderRef.child(fileName).putFile(localFile, metadata);
    return snapshot.ref.getDownloadURL();
  }

  Future<ui.Image> _decode(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    return (await codec.getNextFrame()).image;
  }

  @override
  Future<void> sendMessage(OutgoingMessage message,
      {String? imageUrl, String? docUrl}) async {
    await _messages(message.roomId).add({
      'senderId': message.senderId,
      'receiverId': message.receiverId,
      'message': message.text,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
      'type': message.type.name,
      'imageUrl': imageUrl,
      'docUrl': docUrl,
      'repliedMessageId': message.repliedMessageId,
      'repliedMessageContent': message.repliedMessageContent,
      'repliedMessageSender': message.repliedMessageSender,
      'repliedMessageType': message.repliedMessageType,
    });

    var summary = message.text;
    if (message.type == MessageType.image) summary = '📷 Photo';
    if (message.type == MessageType.doc) summary = '📄 ${message.text}';
    if (message.repliedMessageId != null) summary = '↪ $summary';

    await _rooms.doc(message.roomId).update({
      'lastMessage': summary,
      'lastMessageTimestamp': FieldValue.serverTimestamp(),
      if (!message.skipUnreadIncrement)
        'unreadCount_${message.receiverId}': FieldValue.increment(1),
    });

    // Notify the receiver (best-effort).
    try {
      final senderData =
          (await firestore.collection('users').doc(message.senderId).get())
                  .data() ??
              {};
      final senderName =
          senderData['name'] ?? senderData['username'] ?? 'Someone';
      await NotificationService.createNotification(
        recipientId: message.receiverId,
        senderId: message.senderId,
        type: NotificationType.requestChatPrivate,
        title: 'New message from $senderName',
        description: summary.isNotEmpty ? summary : 'Sent a message',
        subtitle: message.roomId,
      );
    } catch (e) {
      debugPrint('Failed to send private chat notification: $e');
    }
  }

  @override
  Future<void> toggleReaction({
    required String roomId,
    required String messageId,
    required String userId,
    required String emoji,
  }) async {
    final docRef = _messages(roomId).doc(messageId);
    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;
      final reactions =
          Map<String, dynamic>.from(snapshot.data()!['reactions'] as Map? ?? {});
      transaction.update(docRef, {
        'reactions.$userId':
            reactions[userId] == emoji ? FieldValue.delete() : emoji,
      });
    });
  }

  @override
  Future<void> deleteMessage(
      String roomId, ChatMessage message, String currentUid) async {
    for (final url in [message.imageUrl, message.docUrl]) {
      if (url != null && url.isNotEmpty) await _deleteStorageFile(url);
    }
    final userName = await _userName(currentUid);
    await _messages(roomId).doc(message.messageId).update({
      'message': 'Deleted by $userName',
      'type': 'text',
      'imageUrl': null,
      'docUrl': null,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// Best-effort: a missing file must not block deleting the message.
  Future<void> _deleteStorageFile(String url) async {
    try {
      final path = Uri.decodeComponent(Uri.parse(url).path.split('/o/').last);
      await storage.ref().child(path).delete();
    } catch (e) {
      debugPrint('Storage file deletion skipped: $e');
    }
  }

  @override
  Future<void> pinMessage(String roomId, ChatMessage message, String byUid) {
    return _pin(roomId).set(
      PinnedMessageModel.toJson(
        messageId: message.messageId,
        content: message.message,
        pinnedBy: byUid,
      ),
      SetOptions(merge: true),
    );
  }

  @override
  Future<void> unpinMessage(String roomId) => _pin(roomId).delete();

  @override
  Future<RoomDetails> getRoomDetails(String roomId, String currentUid) async {
    final doc = await _rooms.doc(roomId).get();
    if (!doc.exists) throw const ServerException('Room not found');
    final data = doc.data()!;
    final participants = List<String>.from(data['participants'] ?? []);
    final otherUid = participants.firstWhere(
      (id) => id != currentUid,
      orElse: () => currentUid,
    );
    return RoomDetails(
      participantName: await _userName(otherUid, fallback: 'Unknown'),
      lastMessage: data['lastMessage'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  @override
  Future<List<String>> getSharedImages(String roomId) async {
    final query = await _messages(roomId).where('type', isEqualTo: 'image').get();
    return query.docs
        .map((doc) => doc.data()['imageUrl'] as String?)
        .whereType<String>()
        .where((url) => url.isNotEmpty)
        .toList();
  }

  @override
  Future<List<SharedFile>> getSharedDocuments(String roomId) async {
    final query = await _messages(roomId).where('type', isEqualTo: 'doc').get();
    return query.docs
        .map((doc) {
          final data = doc.data();
          return SharedFile(
            url: data['docUrl'] as String? ?? '',
            name: data['message'] as String? ?? 'Unknown file',
            timestamp:
                (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
          );
        })
        .where((file) => file.url.isNotEmpty)
        .toList();
  }

  @override
  Future<String?> getPhoneNumber(String uid) async {
    final doc = await firestore.collection('users').doc(uid).get();
    return doc.data()?['phoneNumber'] as String?;
  }
}
