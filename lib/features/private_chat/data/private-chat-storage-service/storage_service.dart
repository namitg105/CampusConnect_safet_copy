// storage_service.dart
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads an image to Firebase Storage under the folder scheme:
  /// private_chat/images/images_{uid}/
  /// Names the file based on the item index sequence count.
  Future<String?> uploadChatImage({
    required XFile imageFile,
    required String senderUid,
  }) async {
    try {
      final File file = File(imageFile.path);

      // Get reference to the user's specific storage folder
      final String folderPath = 'private_chat/images/images_$senderUid';
      final Reference folderRef = _storage.ref().child(folderPath);

      // 1. Constraint 2: Calculate target name index dynamically by counting existing files
      int nextIndex = 1;
      try {
        final ListResult listResult = await folderRef.listAll();
        nextIndex = listResult.items.length + 1;
      } catch (e) {
        // Fallback if folder listing fails or doesn't exist yet
        nextIndex = DateTime.now().millisecondsSinceEpoch;
      }

      // Determine clean format extension
      final String fileExtension = imageFile.name.split('.').last.toLowerCase();
      final String finalFileName = '$nextIndex.$fileExtension';

      // 2. Set structural references
      final Reference targetFileRef = folderRef.child(finalFileName);

      // 3. Constraint 4: Read dimensions and map out complete custom metadata payloads
      final decodedImage = await decodeImageFromList(await file.readAsBytes());

      final SettableMetadata metadata = SettableMetadata(
        contentType: 'image/$fileExtension',
        customMetadata: {
          'imageName': finalFileName,
          'imageOwner': senderUid,
          'timestamp': DateTime.now().toIso8601String(),
          'width': decodedImage.width.toString(),
          'height': decodedImage.height.toString(),
          'format': fileExtension,
        },
      );

      // 4. Fire upload pipeline task
      final UploadTask uploadTask = targetFileRef.putFile(file, metadata);
      final TaskSnapshot snapshot = await uploadTask;

      // Return accessible link representation for UI distribution tracking
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Storage Upload Exception Error: $e");
      return null;
    }
  }

  String _getStoragePathFromUrl(String url) {
    // Decoding Firebase Storage format paths cleanly
    final Uri uri = Uri.parse(url);
    final String pathWithMedia = uri.path.split('/o/').last;
    return Uri.decodeComponent(pathWithMedia);
  }

  /// Deletes the source media asset directly from Firebase Cloud Storage
  Future<void> deleteStorageFileByUrl(String fileUrl) async {
    try {
      final String storagePath = _getStoragePathFromUrl(fileUrl);
      await _storage.ref().child(storagePath).delete();
    } catch (e) {
      print("Warning: Storage asset deletion skipped/failed: $e");
    }
  }

  // ==================== NEW DOCUMENT FUNCTION ====================

  /// Uploads a document to Firebase Storage under the folder scheme:
  /// private_chat/documents/doc_{uid}/
  /// Names the file sequentially matching Constraint-3 (1 + total docs).
  Future<String?> uploadChatDoc({
    required XFile docFile,
    required String senderUid,
  }) async {
    try {
      final File file = File(docFile.path);

      // Constraint 1 & 2: Define specific folder destination location paths
      final String folderPath = 'private_chat/documents/doc_$senderUid';
      final Reference folderRef = _storage.ref().child(folderPath);

      // Constraint 3: Resolve name index sequentially by tracking size metrics
      int nextIndex = 1;
      try {
        final ListResult listResult = await folderRef.listAll();
        nextIndex = listResult.items.length + 1;
      } catch (e) {
        nextIndex = DateTime.now().millisecondsSinceEpoch;
      }

      final String fileExtension = docFile.name.split('.').last.toLowerCase();
      final String finalDocName = '$nextIndex.$fileExtension';
      final Reference targetFileRef = folderRef.child(finalDocName);

      // Build out standard structural content-type maps
      final SettableMetadata metadata = SettableMetadata(
        contentType: 'application/$fileExtension',
        customMetadata: {
          'documentName': finalDocName,
          'documentOwner': senderUid,
          'timestamp': DateTime.now().toIso8601String(),
          'format': fileExtension,
        },
      );

      final UploadTask uploadTask = targetFileRef.putFile(file, metadata);
      final TaskSnapshot snapshot = await uploadTask;

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Document Storage Upload Exception Error: $e");
      return null;
    }
  }
}
