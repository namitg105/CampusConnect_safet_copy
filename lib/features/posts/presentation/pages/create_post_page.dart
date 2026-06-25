import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noteswap/features/auth/domain/entities/app_user.dart';
import 'package:noteswap/features/posts/presentation/controllers/post_controller.dart';

class CreatePostPage extends StatefulWidget {
  final PostController controller;
  final AppUser currentUser;

  const CreatePostPage({super.key, required this.controller, required this.currentUser});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final titleController = TextEditingController();
  final bodyController = TextEditingController();
  final tagController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final tags = ['General', 'Study', 'Events', 'ExamHelp', 'Seniors', 'Badminton'];
  String selectedTag = 'General';

  @override
  void dispose() {
    titleController.dispose();
    bodyController.dispose();
    tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Post')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                validator: (value) => (value ?? '').trim().isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: bodyController,
                maxLines: 6,
                decoration: const InputDecoration(labelText: 'Body', border: OutlineInputBorder()),
                validator: (value) => (value ?? '').trim().isEmpty ? 'Please enter some content' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedTag,
                decoration: const InputDecoration(labelText: 'Tag', border: OutlineInputBorder()),
                items: tags
                    .map((tag) => DropdownMenuItem(value: tag, child: Text(tag)))
                    .toList(),
                onChanged: (value) => setState(() => selectedTag = value ?? 'General'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: tagController,
                decoration: const InputDecoration(labelText: 'Custom tag (optional)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  final tag = (tagController.text.trim().isEmpty ? selectedTag : tagController.text.trim());
                  await widget.controller.addPost(
                    title: titleController.text,
                    body: bodyController.text,
                    author: widget.currentUser,
                    tag: tag,
                  );
                  if (widget.controller.errorMessage.value.isEmpty) {
                    Get.back();
                  }
                },
                child: const Text('Post'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
