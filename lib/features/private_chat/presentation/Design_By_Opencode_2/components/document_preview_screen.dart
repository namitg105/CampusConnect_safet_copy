// document_preview_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:noteswap/features/private_chat/data/private-chat-services/user_service.dart';
import 'package:noteswap/features/private_chat/data/private-chat-storage-service/storage_service.dart';
import 'package:noteswap/features/private_chat/domain/entities/chat_message.dart';
import 'package:noteswap/features/private_chat/domain/repos/chat_controller.dart';

class DocumentPreviewScreen extends StatelessWidget {
  final String docPath;
  final String targetUser;
  final XFile docFile;

  const DocumentPreviewScreen({
    super.key,
    required this.docFile,
    required this.docPath,
    required this.targetUser,
  });

  @override
  Widget build(BuildContext context) {
    final String extension = docFile.name.split('.').last.toUpperCase();

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Preview Document',
            style: TextStyle(color: Colors.white)),
      ),
      body: Stack(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 32.0),
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.description,
                      size: 72, color: Colors.redAccent),
                  const SizedBox(height: 16),
                  Text(
                    docFile.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(extension,
                        style: const TextStyle(color: Colors.white)),
                    backgroundColor: Colors.redAccent,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            right: 24,
            child: FloatingActionButton(
              backgroundColor: Colors.blueAccent,
              onPressed: () async {
                Get.dialog(
                  const Center(
                      child:
                          CircularProgressIndicator(color: Colors.blueAccent)),
                  barrierDismissible: false,
                );

                final chatController = Get.isRegistered<ChatController>()
                    ? Get.find<ChatController>()
                    : Get.put(ChatController());
                final authController = Get.find<UserService>();
                final StorageService storageService = StorageService();

                final myUid = authController.currentUser?.uid;
                final roomId = chatController.currentRoomId.value;

                if (myUid != null &&
                    roomId.isNotEmpty &&
                    targetUser.isNotEmpty) {
                  // Upload using the new document function
                  final String? uploadedUrl =
                      await storageService.uploadChatDoc(
                    docFile: docFile,
                    senderUid: myUid,
                  );

                  if (uploadedUrl != null) {
                    // Change your chatController.sendMessage block inside document preview FAB to look like this:
                    await chatController.sendMessage(
                      roomId: roomId,
                      senderId: myUid,
                      receiverId: targetUser,
                      message: docFile.name,
                      type: MessageType.doc,
                      docUrl: uploadedUrl,
                    );
                    /*
                    await chatController.sendMessage(
                      roomId: roomId,
                      senderId: myUid,
                      receiverId: targetUser,
                      message: "📄 ${docFile.name}",
                      type: MessageType.text
                    );*/
                  }
                }
                Get.close(
                    2); // Closes dialog + pushes view profile pipeline backwards
              },
              child: const Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
