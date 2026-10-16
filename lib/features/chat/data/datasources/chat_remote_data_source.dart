import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/error/exceptions.dart';
import '../../../events/notifications/models/notification_model.dart';
import '../../../events/notifications/services/notification_service.dart';
import '../../../security/aes_service.dart';
import '../../domain/entities/message.dart';
import '../../domain/repos/chat_repo.dart';
import '../models/message_model.dart';

/// Firestore (messages, pins), Storage (media) and the media compression
/// steps for community chats.
abstract interface class ChatRemoteDataSource {
  Stream<List<MessageModel>> watchMessages(String groupId);
  Future<void> sendText(String groupId, String text);
  Future<void> sendMedia(String groupId, MediaKind kind, ChatAttachment file);
  Future<void> deleteMessage(String groupId, String messageId);
  Future<void> pinMessage(String groupId, String messageId);
  Future<void> unpinMessage(String groupId);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final FirebaseStorage storage;
  final AESService aes;

  const ChatRemoteDataSourceImpl({
    required this.firestore,
    required this.auth,
    required this.storage,
    required this.aes,
  });

  CollectionReference<Map<String, dynamic>> _messages(String groupId) =>
      firestore.collection('chats').doc(groupId).collection('messages');

  String get _stamp => DateTime.now().millisecondsSinceEpoch.toString();

  @override
  Stream<List<MessageModel>> watchMessages(String groupId) {
    return _messages(groupId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromMap(doc.id, doc.data(), aes))
            .toList());
  }

  @override
  Future<void> sendText(String groupId, String text) async {
    if (text.trim().isEmpty) return;
    await _send(groupId, type: 'text', text: text.trim());
  }

  @override
  Future<void> sendMedia(
      String groupId, MediaKind kind, ChatAttachment file) async {
    switch (kind) {
      case MediaKind.image:
        final upload = await _compressImage(file.path);
        final url = await _upload(
            'chat_media/images/$groupId/$_stamp.jpg', upload);
        await _send(groupId, type: 'image', text: '', mediaUrl: url);
      case MediaKind.video:
        final compressed = await _compressVideo(file.path);
        try {
          final url = await _upload(
              'chat_media/videos/$groupId/$_stamp.mp4', compressed);
          await _send(groupId, type: 'video', text: '', mediaUrl: url);
        } finally {
          if (await compressed.exists()) await compressed.delete();
        }
      case MediaKind.document:
        final source = File(file.path);
        if (!await source.exists()) {
          throw const ServerException('Selected file does not exist.');
        }
        final url = await _upload(
          'chat_media/documents/$groupId/${_stamp}_${file.name}',
          source,
          contentType: file.extension == 'pdf'
              ? 'application/pdf'
              : 'application/octet-stream',
        );
        await _send(groupId, type: 'document', text: file.name, mediaUrl: url);
    }
  }

  Future<File> _compressImage(String path) async {
    final tempDir = await getTemporaryDirectory();
    final compressed = await FlutterImageCompress.compressAndGetFile(
      path,
      '${tempDir.path}/$_stamp.jpg',
      quality: 35,
      minWidth: 500,
      minHeight: 500,
      format: CompressFormat.jpeg,
    );
    return File(compressed?.path ?? path);
  }

  /// Re-encodes to 480p H.264 so uploads stay small.
  Future<File> _compressVideo(String path) async {
    final tempDir = await getTemporaryDirectory();
    final outputPath = '${tempDir.path}/$_stamp.mp4';
    await FFmpegKit.execute(
      '-i "$path" '
      '-vf "scale=854:480:force_original_aspect_ratio=decrease" '
      '-c:v libx264 '
      '-preset fast '
      '-crf 28 '
      '-b:v 800k '
      '-c:a aac '
      '-b:a 96k '
      '-movflags +faststart '
      '"$outputPath"',
    );
    return File(outputPath);
  }

  Future<String> _upload(String storagePath, File file,
      {String? contentType}) async {
    final ref = storage.ref(storagePath);
    await ref.putFile(
      file,
      contentType == null ? null : SettableMetadata(contentType: contentType),
    );
    return ref.getDownloadURL();
  }

  /// Writes the message as the logged-in user, then notifies the other
  /// members (best-effort).
  Future<void> _send(
    String groupId, {
    required String type,
    required String text,
    String? mediaUrl,
  }) async {
    final user = auth.currentUser;
    if (user == null) throw const ServerException('User not logged in.');

    final userData =
        (await firestore.collection('users').doc(user.uid).get()).data();
    final senderName =
        userData?['name'] ?? user.displayName ?? user.email ?? 'User';

    final message = Message(
      id: '',
      senderId: user.uid,
      senderName: senderName,
      senderImage: userData?['profileImage'] as String?,
      text: text,
      type: type,
      mediaUrl: mediaUrl,
      createdAt: DateTime.now(),
    );
    await _messages(groupId).add(MessageModel.toMap(message, aes));

    try {
      final groupDoc = await firestore.collection('groups').doc(groupId).get();
      final groupName = groupDoc.data()?['name'] ?? 'Community';
      final members = await firestore
          .collection('groups')
          .doc(groupId)
          .collection('members')
          .get();
      for (final memberDoc in members.docs) {
        if (memberDoc.id == user.uid) continue;
        await NotificationService.createNotification(
          recipientId: memberDoc.id,
          type: NotificationType.requestChatGroup,
          title: '$groupName: New message',
          description: '$senderName: $text',
          subtitle: groupId,
        );
      }
    } catch (e) {
      debugPrint('Failed to send group message notification: $e');
    }
  }

  @override
  Future<void> deleteMessage(String groupId, String messageId) =>
      _messages(groupId).doc(messageId).delete();

  @override
  Future<void> pinMessage(String groupId, String messageId) {
    return firestore.collection('groups').doc(groupId).update({
      'pinnedMessageId': messageId,
      'pinnedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> unpinMessage(String groupId) {
    return firestore.collection('groups').doc(groupId).update({
      'pinnedMessageId': FieldValue.delete(),
      'pinnedAt': FieldValue.delete(),
    });
  }
}
