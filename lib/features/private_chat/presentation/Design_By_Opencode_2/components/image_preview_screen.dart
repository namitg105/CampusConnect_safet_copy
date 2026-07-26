// image_preview_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:noteswap/features/private_chat/data/private-chat-services/user_service.dart';
import 'package:noteswap/features/private_chat/data/private-chat-storage-service/storage_service.dart';
import 'package:noteswap/features/private_chat/domain/entities/chat_message.dart';
import 'package:noteswap/features/private_chat/domain/repos/chat_controller.dart';

class ImagePreviewScreen extends StatelessWidget {
  final String imagePath;
  final String targetUser;
  final XFile imageFile;

  const ImagePreviewScreen(
      {super.key,
      required this.imageFile,
      required this.imagePath,
      required this.targetUser});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title:
            const Text('Preview Image', style: TextStyle(color: Colors.white)),
      ),
      body: Stack(
        children: [
          Center(
            child: Image.file(
              File(imagePath),
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            bottom: 24,
            right: 24,
            child: // Inside ImagePreviewScreen floating action button:
                FloatingActionButton(
              backgroundColor: Colors.blueAccent,
              onPressed: () async {
                Get.dialog(
                  const Center(
                      child:
                          CircularProgressIndicator(color: Colors.blueAccent)),
                  barrierDismissible: false,
                );

                final chatController = Get.find<ChatController>();
                final authController = Get.find<UserService>();
                final StorageService storageService = StorageService();

                final myUid = authController.currentUser?.uid;
                final roomId = chatController.currentRoomId.value;
                final targetUid = targetUser;

                if (myUid != null &&
                    roomId.isNotEmpty &&
                    targetUid.isNotEmpty) {
                  final String? uploadedUrl =
                      await storageService.uploadChatImage(
                    imageFile: imageFile,
                    senderUid: myUid,
                  );
                  if (uploadedUrl != null) {
                    // 2. Publish new item document mapping payload to firestore sub-collection
                    await chatController.sendMessage(
                      roomId: roomId,
                      senderId: myUid,
                      receiverId:
                          targetUser, // Assuming your passed variable acts as the raw Target Participant Uid String here
                      message: "📷 Photo",
                      type: MessageType.image,
                      imageUrl: uploadedUrl,
                    );
                  }
                }

                Get.close(2);
                /*
                  chatController.sendMessage(
                    roomId: roomId,
                    senderId: myUid,
                    receiverId: targetUid,
                    message: "image by $myUid",
                    type: MessageType.image,
                    imageUrl: uploadedUrl,
                  );
                }
                Get.back();*/
              },
              child: const Icon(Icons.send, color: Colors.white),
            ),
            /*
            FloatingActionButton(
              backgroundColor: Colors.blueAccent,
              onPressed: () {
                // TODO: Handle sending image to Firestore later
                Get.back();
              },
              child: const Icon(Icons.send, color: Colors.white),
            ),*/
          ),
        ],
      ),
    );
  }
}
