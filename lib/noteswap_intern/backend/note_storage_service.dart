import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

import 'note_models.dart';

/// Result of a successful storage upload for a note.
class UploadedNoteFiles {
  final String fileUrl;
  final List<String> previewUrls;

  const UploadedNoteFiles(this.fileUrl, this.previewUrls);
}

/// Handles all Firebase Storage operations for the noteswap module.
///
/// Layout:
///   noteswap/notes/{userId}-notes/{epoch}_{sanitizedFileName}
///   noteswap/notes/{userId}-notes/previews/{epoch}_{sanitizedFileName}.{ext}
///
/// One folder per user (created implicitly on first upload, reused later).
class NoteStorageService {
  Future<UploadedNoteFiles> uploadNote({
    required NoteUploadData data,
    required String uid,
  }) async {
    final uploadedRefs = <Reference>[];
    try {
      final epoch = DateTime.now().millisecondsSinceEpoch;
      final safeName = _sanitize(data.fileName);
      final folder = 'noteswap/notes/$uid-notes';

      final fileRef = FirebaseStorage.instance
          .ref('$folder/${epoch}_$safeName');
      await fileRef.putFile(
        File(data.filePath),
        SettableMetadata(contentType: _contentType(data.fileName)),
      );
      uploadedRefs.add(fileRef);
      final fileUrl = await fileRef.getDownloadURL();

      final previewUrls = <String>[];
      for (var i = 0; i < data.previewPaths.length; i++) {
        final path = data.previewPaths[i];
        final ext = path.split('.').last.toLowerCase();
        final pRef = FirebaseStorage.instance.ref(
          '$folder/previews/${epoch}_$safeName$i${ext.isEmpty ? '' : '.$ext'}',
        );
        await pRef.putFile(
          File(path),
          SettableMetadata(contentType: _imageContentType(ext)),
        );
        uploadedRefs.add(pRef);
        previewUrls.add(await pRef.getDownloadURL());
      }

      return UploadedNoteFiles(fileUrl, previewUrls);
    } catch (e) {
      // Roll back any files uploaded before the failure so Storage does not
      // accumulate orphans (main file + previews).
      for (final ref in uploadedRefs) {
        try {
          await ref.delete();
        } catch (_) {}
      }
      // Only a real quota/billing failure should surface as "credits ended".
      // Everything else rethrows the actual error (permissions, network, ...).
      if (e is FirebaseException && _isStorageQuotaError(e)) {
        throw const StorageCreditException();
      }
      rethrow;
    }
  }

  /// Deletes the note file and its preview images from Storage (hard delete).
  Future<void> deleteNoteFiles({
    required String fileUrl,
    required List<String> previewUrls,
  }) async {
    for (final url in [fileUrl, ...previewUrls]) {
      final path = pathFromDownloadUrl(url);
      if (path.isEmpty) continue;
      try {
        await FirebaseStorage.instance.ref(path).delete();
      } catch (_) {
        // Best-effort cleanup.
      }
    }
  }

  /// Extracts the storage path from a download URL such as
  ///   https://firebasestorage.googleapis.com/v0/b/.../o/...?alt=media&amp;token=...
  String pathFromDownloadUrl(String url) {
    try {
      final match = RegExp(r'/o/(.+?)\?alt=media').firstMatch(url);
      if (match != null) return Uri.decodeComponent(match.group(1)!);
    } catch (_) {}
    return '';
  }

  /// True when the exception indicates the Storage quota/billing is exhausted.
  bool _isStorageQuotaError(FirebaseException e) {
    final code = e.code.toLowerCase();
    if (code.contains('quota') ||
        code.contains('payment') ||
        code.contains('limit')) {
      return true;
    }
    final message = e.message?.toLowerCase() ?? '';
    return message.contains('quota') || message.contains('limit exceeded');
  }

  String _sanitize(String name) {
    final base = name.replaceAll(RegExp(r'[^\w.\-]'), '_');
    return base.isEmpty ? 'file' : base;
  }

  String _contentType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'ppt':
        return 'application/vnd.ms-powerpoint';
      case 'pptx':
        return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
      default:
        return 'application/octet-stream';
    }
  }

  String _imageContentType(String ext) {
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      default:
        return 'image/$ext';
    }
  }
}
