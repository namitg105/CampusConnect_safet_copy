import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/entities/message.dart';
import '../../domain/repos/chat_repo.dart';
import 'chat_states.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepo repo;

  StreamSubscription? _sub;

  ChatCubit(this.repo) : super(ChatInitial());

  final ImagePicker _picker = ImagePicker();

  /// Current logged in user id
  String get currentUserId => FirebaseAuth.instance.currentUser?.uid ?? "";

  void loadMessages(String groupId) {
    emit(ChatLoading());

    _sub?.cancel();

    _sub = repo.getMessages(groupId).listen(
      (messages) {
        emit(ChatLoaded(messages));
      },
      onError: (e) {
        emit(ChatError(e.toString()));
      },
    );
  }

  Future<void> reactToMessage({
    required String groupId,
    required String messageId,
    required String emoji,
    required String userId,
  }) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .collection('messages')
          .doc(messageId);

      final snapshot = await docRef.get();
      if (!snapshot.exists) return;

      Map<String, dynamic> reactions =
          Map<String, dynamic>.from(snapshot.data()?['reactions'] ?? {});

      // If the user already reacted with the same emoji, toggle it off
      if (reactions[userId] == emoji) {
        reactions.remove(userId);
      } else {
        reactions[userId] = emoji; // Add or replace reaction
      }

      await docRef.update({'reactions': reactions});
    } catch (e) {
      debugPrint("Error reacting to message: $e");
    }
  }

  /// Updates the group metadata to point to a specific message ID as pinned.
  Future<void> pinMessage({
    required String groupId,
    required String messageId,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .update({
        'pinnedMessageId': messageId,
        'pinnedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      emit(ChatError("Failed to pin message: $e"));
    }
  }

  /// Removes the pinned message pointer from the group document metadata.
  Future<void> unpinMessage({required String groupId}) async {
    try {
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .update({
        'pinnedMessageId': FieldValue.delete(),
        'pinnedAt': FieldValue.delete(),
      });
    } catch (e) {
      emit(ChatError("Failed to unpin message: $e"));
    }
  }

  Future<String> _getSenderName(User? user) async {
    if (user == null) return "User";

    try {
      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();

      return doc.data()?["name"] ?? user.displayName ?? user.email ?? "User";
    } catch (_) {
      return user.displayName ?? user.email ?? "User";
    }
  }

  Future<void> sendMessage({
    required String groupId,
    required String text,
  }) async {
    if (text.trim().isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    final senderName = await _getSenderName(user);

    final message = Message(
      id: "",
      senderId: user?.uid ?? "",
      senderName: senderName,
      text: text.trim(),
      type: "text",
      mediaUrl: null,
      createdAt: Timestamp.now(),
    );

    await repo.sendMessage(groupId, message);
  }

  Future<void> sendImage(String groupId) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image == null) return;

    final user = FirebaseAuth.instance.currentUser;
    final senderName = await _getSenderName(user);

    final tempDir = await getTemporaryDirectory();

    final compressedPath =
        "${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg";

    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      image.path,
      compressedPath,
      quality: 35,
      minWidth: 500,
      minHeight: 500,
      format: CompressFormat.jpeg,
    );

    final fileToUpload = File(
      compressedFile?.path ?? image.path,
    );

    final ref = FirebaseStorage.instance.ref().child(
          "chat_media/images/$groupId/${DateTime.now().millisecondsSinceEpoch}.jpg",
        );

    await ref.putFile(fileToUpload);

    final downloadUrl = await ref.getDownloadURL();

    final message = Message(
      id: "",
      senderId: user?.uid ?? "",
      senderName: senderName,
      text: "",
      type: "image",
      mediaUrl: downloadUrl,
      createdAt: Timestamp.now(),
    );

    await repo.sendMessage(groupId, message);
  }

  Future<void> sendVideo(String groupId) async {
    final XFile? video = await _picker.pickVideo(
      source: ImageSource.gallery,
    );

    if (video == null) return;

    final user = FirebaseAuth.instance.currentUser;
    final senderName = await _getSenderName(user);

    final tempDir = await getTemporaryDirectory();

    final outputPath =
        "${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.mp4";

    await FFmpegKit.execute(
      '-i "${video.path}" '
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

    final compressedFile = File(outputPath);

    final ref = FirebaseStorage.instance.ref().child(
          "chat_media/videos/$groupId/${DateTime.now().millisecondsSinceEpoch}.mp4",
        );

    await ref.putFile(compressedFile);

    final downloadUrl = await ref.getDownloadURL();

    final message = Message(
      id: "",
      senderId: user?.uid ?? "",
      senderName: senderName,
      text: "",
      type: "video",
      mediaUrl: downloadUrl,
      createdAt: Timestamp.now(),
    );

    await repo.sendMessage(groupId, message);

    if (await compressedFile.exists()) {
      await compressedFile.delete();
    }
  }

  /// Delete message
  Future<void> deleteMessage({
    required String groupId,
    required String messageId,
  }) async {
    try {
      await repo.deleteMessage(
        groupId: groupId,
        messageId: messageId,
      );
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> sendDocument(String groupId) async {
    try {
      print("Opening file picker...");

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: false,
        allowedExtensions: [
          'pdf',
          'doc',
          'docx',
          'ppt',
          'pptx',
          'xls',
          'xlsx',
          'txt',
          'zip',
          'rar',
        ],
      );

      if (result == null) {
        print("User cancelled file picker");
        return;
      }

      final picked = result.files.single;

      if (picked.path == null) {
        throw Exception("Selected file path is null.");
      }

      final file = File(picked.path!);

      if (!await file.exists()) {
        throw Exception("Selected file does not exist.");
      }

      print("Selected file: ${picked.name}");
      print("Size: ${picked.size} bytes");

      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception("User not logged in.");
      }

      final senderName = await _getSenderName(user);

      final storagePath =
          "chat_media/documents/$groupId/${DateTime.now().millisecondsSinceEpoch}_${picked.name}";

      print("Uploading to:");
      print(storagePath);

      final ref = FirebaseStorage.instance.ref(storagePath);

      final uploadTask = ref.putFile(
        file,
        SettableMetadata(
          contentType: picked.extension == "pdf"
              ? "application/pdf"
              : "application/octet-stream",
        ),
      );

      await uploadTask;

      print("Upload completed");

      final downloadUrl = await ref.getDownloadURL();

      print("Download URL:");
      print(downloadUrl);

      final message = Message(
        id: "",
        senderId: user.uid,
        senderName: senderName,
        text: picked.name,
        type: "document",
        mediaUrl: downloadUrl,
        createdAt: Timestamp.now(),
      );

      await repo.sendMessage(groupId, message);

      print("Firestore message saved");
    } on FirebaseException catch (e) {
      print("Firebase Error");
      print("Code: ${e.code}");
      print("Message: ${e.message}");
    } catch (e, s) {
      print("Document Upload Error");
      print(e);
      print(s);
    }
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
