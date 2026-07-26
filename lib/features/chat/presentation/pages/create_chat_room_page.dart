import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noteswap/features/auth/domain/entities/app_user.dart';

class CreateChatRoomPage extends StatefulWidget {
  final AppUser currentUser;

  const CreateChatRoomPage({super.key, required this.currentUser});

  @override
  State<CreateChatRoomPage> createState() => _CreateChatRoomPageState();
}

class _CreateChatRoomPageState extends State<CreateChatRoomPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void _createRoom() {
    final roomName = nameController.text.trim();
    if (roomName.isEmpty) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Room "$roomName" created (UI only)'),
      ),
    );
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Chat Room'),
        backgroundColor: isLightMode ? Colors.white : const Color(0xFF121212),
        iconTheme: IconThemeData(color: isLightMode ? Colors.black : Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Room name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _createRoom,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6139ED),
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('Create room'),
            ),
          ],
        ),
      ),
    );
  }
}
