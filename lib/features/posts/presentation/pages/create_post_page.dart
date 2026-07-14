import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
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
  final tags = ['Select recommended tag', 'General', 'Study', 'Events', 'ExamHelp', 'Seniors', 'Badminton'];
  String selectedTag = 'Select recommended tag';

  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    titleController.dispose();
    bodyController.dispose();
    tagController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Post')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          final isLoading = widget.controller.isLoading.value;
          return Form(
            key: formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                  validator: (value) => (value ?? '').trim().isEmpty ? 'Please enter a title' : null,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: bodyController,
                  maxLines: 6,
                  decoration: const InputDecoration(labelText: 'Body', border: OutlineInputBorder()),
                  validator: (value) => (value ?? '').trim().isEmpty ? 'Please enter some content' : null,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedTag,
                  decoration: const InputDecoration(labelText: 'Tag', border: OutlineInputBorder()),
                  items: tags
                      .map((tag) => DropdownMenuItem(value: tag, child: Text(tag)))
                      .toList(),
                  onChanged: isLoading ? null : (value) => setState(() => selectedTag = value ?? 'Select recommended tag'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: tagController,
                  decoration: const InputDecoration(labelText: 'Custom tag (optional)', border: OutlineInputBorder()),
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),
                
                // Gallery image selector and preview
                if (_selectedImage != null)
                  Stack(
                    children: [
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: FileImage(File(_selectedImage!.path)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: CircleAvatar(
                          backgroundColor: Colors.black54,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: isLoading ? null : () => setState(() => _selectedImage = null),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  OutlinedButton.icon(
                    onPressed: isLoading ? null : _pickImage,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Add Photo from Gallery'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFF6139ED)),
                      foregroundColor: const Color(0xFF6139ED),
                    ),
                  ),
                
                const SizedBox(height: 24),
                if (isLoading)
                  const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF6139ED),
                    ),
                  )
                else
                  ElevatedButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      final hasCustom = tagController.text.trim().isNotEmpty;
                      final hasRecommended = selectedTag != 'Select recommended tag';

                      if (hasCustom && hasRecommended) {
                        Get.snackbar(
                          'Tag Warning',
                          'Please choose only one: select a recommended tag OR enter a custom tag.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.orange,
                          colorText: Colors.white,
                        );
                        return;
                      }

                      if (!hasCustom && !hasRecommended) {
                        Get.snackbar(
                          'Tag Warning',
                          'Please select a recommended tag or enter a custom tag.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.orange,
                          colorText: Colors.white,
                        );
                        return;
                      }

                      final tag = hasCustom ? tagController.text.trim() : selectedTag;
                      await widget.controller.addPost(
                        title: titleController.text,
                        body: bodyController.text,
                        author: widget.currentUser,
                        tag: tag,
                        imagePath: _selectedImage?.path,
                        imageName: _selectedImage?.name,
                      );
                      if (widget.controller.errorMessage.value.isEmpty) {
                        Get.back();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6139ED),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Post', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
