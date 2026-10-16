// document_preview_screen.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:noteswap/features/private_chat/domain/entities/chat_message.dart';
import 'attachment_send.dart';

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

    return AttachmentSendListener(
      child: Scaffold(
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
              onPressed: () => AttachmentSendListener.send(
                context,
                path: docFile.path,
                name: docFile.name,
                type: MessageType.doc,
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
