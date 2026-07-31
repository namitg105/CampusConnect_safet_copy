import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:noteswap/features/auth/domain/entities/app_user.dart';
import 'package:noteswap/features/posts/domain/entities/post_entity.dart';
import 'package:noteswap/features/posts/presentation/controllers/post_controller.dart';

class CreatePostPage extends StatefulWidget {
  final PostController controller;
  final AppUser currentUser;

  const CreatePostPage({
    super.key,
    required this.controller,
    required this.currentUser,
  });

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final bodyController = TextEditingController();
  final tagController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // Tracks active tag selection
  String selectedTag = 'Campus Life';
  bool isTagsExpanded = true;
  int currentTextLength = 0;

  final List<String> suggestedTags = [
    'Announcement',
    'Study Tips',
    'Events',
    'Academics',
    'Mental Health',
    'Career',
    'Research',
    'Sports',
    'General',
    'ExamHelp',
    'Seniors',
    'Badminton'
  ];

  XFile? _selectedImage;
  PlatformFile? _selectedFile;
  String? _mediaType;
  final ImagePicker _picker = ImagePicker();

  bool isPollExpanded = false;
  final pollQuestionController = TextEditingController();
  final List<TextEditingController> pollOptionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  @override
  void initState() {
    super.initState();
    bodyController.addListener(() {
      setState(() {
        currentTextLength = bodyController.text.length;
      });
    });
  }

  @override
  void dispose() {
    bodyController.dispose();
    tagController.dispose();
    pollQuestionController.dispose();
    for (var c in pollOptionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'jpg',
          'jpeg',
          'png',
          'gif',
          'mp4',
          'mov',
          'pdf',
          'doc',
          'docx',
          'txt'
        ],
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.size > 50 * 1024 * 1024) {
          Get.snackbar(
            'File Too Large',
            'File size exceeds the 50MB limit.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }
        final ext = file.extension?.toLowerCase() ?? '';
        String type = 'document';
        if (['jpg', 'jpeg', 'png', 'gif'].contains(ext)) {
          type = 'image';
        } else if (['mp4', 'mov'].contains(ext)) {
          type = 'video';
        }

        setState(() {
          _selectedFile = file;
          _mediaType = type;
        });
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick file: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
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

  String getInitials(String name) {
    final cleanName = name.contains('@') ? name.split('@').first : name;
    if (cleanName.trim().isEmpty) return '?';
    final parts = cleanName.trim().split(RegExp(r'[\s._-]+'));
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return cleanName[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    final backgroundColor =
        isLightMode ? const Color(0xFFF4F1FC) : const Color(0xFF121214);
    final cardColor = isLightMode ? Colors.white : const Color(0xFF1E1E22);
    final textColor = isLightMode ? const Color(0xFF1A1A1E) : Colors.white;
    final subTextColor =
        isLightMode ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF);
    final brandColor = const Color(0xFF6139ED);

    final userInitials = getInitials(widget.currentUser.name.isNotEmpty
        ? widget.currentUser.name
        : widget.currentUser.email);
    final userName = widget.currentUser.name.isNotEmpty
        ? widget.currentUser.name
        : (widget.currentUser.email.contains('@')
            ? widget.currentUser.email.split('@').first
            : widget.currentUser.email);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Control Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        color: subTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    'Create Post',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Obx(() {
                    final isLoading = widget.controller.isLoading.value;
                    return GestureDetector(
                      onTap: isLoading
                          ? null
                          : () async {
                              final text = bodyController.text.trim();
                              if (text.isEmpty) {
                                Get.snackbar(
                                  'Post Warning',
                                  'Post content cannot be empty.',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.orange,
                                  colorText: Colors.white,
                                );
                                return;
                              }

                              final tag = selectedTag.trim().isNotEmpty
                                  ? selectedTag.trim()
                                  : 'General';

                              // Extract first sentence/line for Post title
                              final firstLine = text.split('\n').first;
                              final extractedTitle = firstLine.length > 50
                                  ? '${firstLine.substring(0, 47)}...'
                                  : firstLine;

                              PollData? pollData;
                              final pollQ = pollQuestionController.text.trim();
                              final validOptions = pollOptionControllers
                                  .map((c) => c.text.trim())
                                  .where((t) => t.isNotEmpty)
                                  .toList();

                              if (pollQ.isNotEmpty && validOptions.length >= 2) {
                                pollData = PollData(
                                  question: pollQ,
                                  options: validOptions
                                      .map((opt) => PollOption(text: opt, votes: []))
                                      .toList(),
                                );
                              }

                              await widget.controller.addPost(
                                title: extractedTitle,
                                body: text,
                                author: widget.currentUser,
                                tag: tag,
                                imagePath: _selectedFile?.path ?? _selectedImage?.path,
                                imageName: _selectedFile?.name ?? _selectedImage?.name,
                                mediaType: _mediaType ?? (_selectedImage != null ? 'image' : null),
                                mediaName: _selectedFile?.name ?? _selectedImage?.name,
                                poll: pollData,
                              );

                              if (widget
                                  .controller.errorMessage.value.isEmpty) {
                                Navigator.maybePop(context);
                              }
                            },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: isLoading
                              ? brandColor.withOpacity(0.5)
                              : brandColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Post',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            Expanded(
              child: Form(
                key: formKey,
                child: ListView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // Card 1: User details & text input
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: isLightMode
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                        border: Border.all(
                          color: isLightMode
                              ? Colors.grey[100]!
                              : Colors.grey[850]!,
                          width: 0.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              StreamBuilder<DocumentSnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(widget.currentUser.uid)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  final data = snapshot.data?.data() as Map<String, dynamic>?;
                                  final profileImageUrl = data?['profileImage'] as String?;
                                  final hasImage = profileImageUrl != null && profileImageUrl.isNotEmpty;

                                  return CircleAvatar(
                                    radius: 18,
                                    backgroundColor: brandColor.withOpacity(0.15),
                                    backgroundImage: hasImage ? NetworkImage(profileImageUrl) : null,
                                    child: hasImage
                                        ? null
                                        : Text(
                                            userInitials,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: brandColor,
                                            ),
                                          ),
                                  );
                                },
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      userName,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    // Everyone Privacy selector chip
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: brandColor.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.public,
                                              size: 11, color: brandColor),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Everyone',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: brandColor,
                                            ),
                                          ),
                                          const SizedBox(width: 2),
                                          Icon(Icons.keyboard_arrow_down,
                                              size: 11, color: brandColor),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Text input field
                          Stack(
                            children: [
                              TextField(
                                controller: bodyController,
                                maxLines: 6,
                                maxLength: 500,
                                style:
                                    TextStyle(color: textColor, fontSize: 14),
                                decoration: InputDecoration(
                                  hintText: "What's on your mind?",
                                  hintStyle: TextStyle(
                                      color: subTextColor, fontSize: 14),
                                  border: InputBorder.none,
                                  counterText: "",
                                ),
                              ),
                            ],
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                '$currentTextLength/500',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: subTextColor,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 20, thickness: 0.5),

                          // Action items (Feeling, Mention, Location)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildTextActionItem(
                                  Icons.sentiment_satisfied_alt_outlined,
                                  'Feeling',
                                  subTextColor),
                              _buildTextActionItem(Icons.alternate_email,
                                  'Mention', subTextColor),
                              _buildTextActionItem(Icons.location_on_outlined,
                                  'Location', subTextColor),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Card 2: Photo/Video attachment pick zone
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: isLightMode
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                        border: Border.all(
                          color: isLightMode
                              ? Colors.grey[100]!
                              : Colors.grey[850]!,
                          width: 0.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PHOTO / VIDEO',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: subTextColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (_selectedFile != null)
                            Stack(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: brandColor.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        _mediaType == 'image'
                                            ? Icons.image
                                            : (_mediaType == 'video'
                                                ? Icons.videocam
                                                : Icons.insert_drive_file),
                                        color: brandColor,
                                        size: 28,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          _selectedFile!.name,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: textColor,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.black54,
                                    radius: 14,
                                    child: IconButton(
                                      icon: const Icon(Icons.close,
                                          size: 12, color: Colors.white),
                                      onPressed: () => setState(() {
                                        _selectedFile = null;
                                        _mediaType = null;
                                      }),
                                      padding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          else if (_selectedImage != null)
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    File(_selectedImage!.path),
                                    height: 180,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.black54,
                                    radius: 16,
                                    child: IconButton(
                                      icon: const Icon(Icons.close,
                                          size: 14, color: Colors.white),
                                      onPressed: () =>
                                          setState(() => _selectedImage = null),
                                      padding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          else
                            GestureDetector(
                              onTap: _pickFile,
                              child: Container(
                                width: double.infinity,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: brandColor.withOpacity(0.03),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: brandColor.withOpacity(0.15),
                                    width: 1.5,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: brandColor.withOpacity(0.08),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Icons.image_outlined,
                                          color: brandColor, size: 24),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Add Photo or Video',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: brandColor,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'JPG, PNG, GIF, MP4 • Max 50MB',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: subTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Card 3: Create a Poll Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: isLightMode
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                        border: Border.all(
                          color: isLightMode
                              ? Colors.grey[100]!
                              : Colors.grey[850]!,
                          width: 0.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isPollExpanded = !isPollExpanded;
                              });
                            },
                            child: Row(
                              children: [
                                Icon(Icons.bar_chart,
                                    color: brandColor, size: 22),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Create a Poll',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                                Icon(
                                  isPollExpanded
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  size: 18,
                                  color: subTextColor,
                                ),
                              ],
                            ),
                          ),
                          if (isPollExpanded) ...[
                            const SizedBox(height: 14),
                            TextField(
                              controller: pollQuestionController,
                              style: TextStyle(color: textColor, fontSize: 13),
                              decoration: InputDecoration(
                                hintText: 'Ask a question...',
                                hintStyle: TextStyle(
                                    color: subTextColor, fontSize: 13),
                                filled: true,
                                fillColor: isLightMode
                                    ? const Color(0xFFF3F4F6)
                                    : const Color(0xFF2D2D2D),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                              ),
                            ),
                            const SizedBox(height: 10),
                            ...List.generate(pollOptionControllers.length,
                                (index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller:
                                            pollOptionControllers[index],
                                        style: TextStyle(
                                            color: textColor, fontSize: 13),
                                        decoration: InputDecoration(
                                          hintText: 'Option ${index + 1}',
                                          hintStyle: TextStyle(
                                              color: subTextColor,
                                              fontSize: 13),
                                          filled: true,
                                          fillColor: isLightMode
                                              ? const Color(0xFFF3F4F6)
                                              : const Color(0xFF2D2D2D),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide.none,
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 12, vertical: 10),
                                        ),
                                      ),
                                    ),
                                    if (pollOptionControllers.length > 2)
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle,
                                            color: Colors.red, size: 20),
                                        onPressed: () {
                                          setState(() {
                                            pollOptionControllers.removeAt(index);
                                          });
                                        },
                                      ),
                                  ],
                                ),
                              );
                            }),
                            if (pollOptionControllers.length < 5)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      pollOptionControllers
                                          .add(TextEditingController());
                                    });
                                  },
                                  icon: Icon(Icons.add,
                                      color: brandColor, size: 18),
                                  label: Text(
                                    'Add Option',
                                    style: TextStyle(
                                        color: brandColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Card 4: Tags Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: isLightMode
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                        border: Border.all(
                          color: isLightMode
                              ? Colors.grey[100]!
                              : Colors.grey[850]!,
                          width: 0.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isTagsExpanded = !isTagsExpanded;
                              });
                            },
                            child: Row(
                              children: [
                                Icon(Icons.local_offer_outlined,
                                    color: brandColor, size: 18),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Tags',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                                Icon(
                                  isTagsExpanded
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  size: 18,
                                  color: subTextColor,
                                ),
                              ],
                            ),
                          ),
                          if (isTagsExpanded) ...[
                            const SizedBox(height: 12),
                            // Tag Search bar input
                            Container(
                              decoration: BoxDecoration(
                                color: isLightMode
                                    ? const Color(0xFFF3F4F6)
                                    : const Color(0xFF2D2D2D),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Row(
                                children: [
                                  Text('#',
                                      style: TextStyle(
                                          color: subTextColor,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: TextField(
                                      controller: tagController,
                                      style: TextStyle(
                                          color: textColor, fontSize: 13),
                                      decoration: InputDecoration(
                                        hintText: 'Add a tag...',
                                        hintStyle: TextStyle(
                                            color: subTextColor, fontSize: 13),
                                        border: InputBorder.none,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 10),
                                      ),
                                      onSubmitted: (value) {
                                        final trimmed = value.trim();
                                        if (trimmed.isNotEmpty) {
                                          setState(() {
                                            selectedTag = trimmed;
                                            tagController.clear();
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Active Tag Pill selection indicator
                            if (selectedTag.isNotEmpty) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: brandColor,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '#$selectedTag',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedTag = '';
                                        });
                                      },
                                      child: const Icon(
                                        Icons.close,
                                        size: 12,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),
                            ],

                            // Suggested Title
                            Text(
                              'Suggested',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: subTextColor,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Wrap suggested chips
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: suggestedTags.map((tag) {
                                final isSelected = selectedTag == tag;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedTag = tag;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? brandColor
                                          : (isLightMode
                                              ? const Color(0xFFF3F4F6)
                                              : const Color(0xFF2D2D2D)),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isSelected
                                            ? brandColor
                                            : (isLightMode
                                                ? Colors.grey[200]!
                                                : Colors.grey[850]!),
                                        width: 0.5,
                                      ),
                                    ),
                                    child: Text(
                                      '#$tag',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? Colors.white
                                            : textColor,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextActionItem(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: color),
        ),
      ],
    );
  }
}
