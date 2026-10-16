// image_preview_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:noteswap/features/private_chat/domain/entities/chat_message.dart';
import 'attachment_send.dart';

/// Shows the picked photo before sending. Needs the open conversation's
/// `ConversationBloc` (handed over by `ComponentMediaDialog`).
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
    return AttachmentSendListener(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text('Preview Image',
              style: TextStyle(color: Colors.white)),
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
              child: FloatingActionButton(
                backgroundColor: Colors.blueAccent,
                onPressed: () => AttachmentSendListener.send(
                  context,
                  path: imageFile.path,
                  name: imageFile.name,
                  type: MessageType.image,
                  friendUid: targetUser,
                ),
                child: const Icon(Icons.send, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
