// component_media_dialog.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import './document_preview_screen.dart';
import './image_preview_screen.dart';
import '../../common_widgets.dart';

class ComponentMediaDialog {
  ComponentMediaDialog({required this.targetUser});

  final String targetUser;
  final ImagePicker _picker = ImagePicker();
  final List<String> allowedExtensions = ['pdf', 'xlsx', 'xls', 'doc', 'docx'];
  final String errTitle = "Unsupported file type";
  final String errExt = "Only PDF, Excel, and Word files are allowed.";

  void showMediaOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Media Upload'),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.image, color: Colors.blueAccent),
                title: const Text('Image upload'),
                onTap: () async {
                  Navigator.pop(context); // Close dialog
                  final XFile? pickedFile = await _picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (pickedFile != null) {
                    final bytes = await pickedFile.length();
                    if (bytes > 10 * 1024 * 1024) {
                      showErrorSnackbar('Image exceeds 10 MB limit');
                      return;
                    }
                    Get.to(() => ImagePreviewScreen(
                        imageFile: pickedFile,
                        imagePath: pickedFile.path,
                        targetUser: targetUser));
                  }
                },
              ),
              ListTile(
                leading: const Icon(CupertinoIcons.doc_append,
                    color: Colors.redAccent),
                title: const Text('Document upload'),
                onTap: () async {
                  Navigator.pop(context);

                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: allowedExtensions,
                  );

                  if (result != null && result.files.single.path != null) {
                    final PlatformFile pickedPlatformFile = result.files.single;
                    if (pickedPlatformFile.size > 15 * 1024 * 1024) {
                      showErrorSnackbar('Document exceeds 15 MB limit');
                      return;
                    }
                    final XFile docXFile = XFile(
                      pickedPlatformFile.path!,
                      name: pickedPlatformFile.name,
                    );

                    Get.to(() => DocumentPreviewScreen(
                        docFile: docXFile,
                        docPath: docXFile.path,
                        targetUser: targetUser));
                  } else {
                    print("File picking canceled by user");
                  }

                  /*
                  final XFile? pickedFile = await _picker.pickMedia();
                  if (pickedFile != null) {
                    // Extract file extension cleanly
                    final String extension =
                        pickedFile.name.split('.').last.toLowerCase();

                    if (allowedExtensions.contains(extension)) {
                      Get.to(() => DocumentPreviewScreen(
                          docFile: pickedFile,
                          docPath: pickedFile.path,
                          targetUser: targetUser));
                    } else {
                      // Invalid file format -> Block and Notify user
                      final ComponentSnackbar snackbar = ComponentSnackbar();
                      snackbar.SnackBar(title: errTitle, message: errExt);
                    }
                  }
                  
                  if (pickedFile != null) {
                    Get.to(() => DocumentPreviewScreen(
                        docFile: pickedFile,
                        docPath: pickedFile.path,
                        targetUser: targetUser));
                  }*/
                },
              ),
              /*ListTile(
                leading: const Icon(CupertinoIcons.doc_append,
                    color: Colors.redAccent),
                title: const Text('Document upload'),
                onTap: () {
                  Navigator.pop(context); // Close dialog and do nothing
                },
              ),*/
            ],
          ),
        );
      },
    );
  }
}
