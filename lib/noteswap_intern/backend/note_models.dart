import 'package:flutter/material.dart';

/// Input payload for uploading a note to the real backend.
class NoteUploadData {
  final String title;
  final String subject;
  final String courseCode;
  final String semester;
  final String description;
  final num price;
  final bool isFree;
  final String fileName;
  final String filePath;
  final int fileSize;
  final List<String> previewPaths;

  const NoteUploadData({
    required this.title,
    required this.subject,
    required this.courseCode,
    required this.semester,
    required this.description,
    required this.price,
    required this.isFree,
    required this.fileName,
    required this.filePath,
    required this.fileSize,
    this.previewPaths = const [],
  });
}

/// Input payload for rating / reviewing a note.
class ReviewDraft {
  final String noteId;
  final String userId;
  final String userName;
  final num rating;
  final String text;

  const ReviewDraft({
    required this.noteId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.text,
  });
}

/// Thrown when a Firebase Storage upload fails (typically because the
/// project's Storage credits have ended). The UI shows a "Fire storage
/// credits ended" snackbar and stops the flow without writing Firestore.
class StorageCreditException implements Exception {
  final String message;
  const StorageCreditException([this.message = 'Fire storage credits ended']);
  @override
  String toString() => message;
}

/// Thrown when the author tries to delete a note that already has buyers.
/// The UI blocks the delete and shows a top "buys exists at this notes"
/// snackbar.
class NoteHasBuyersException implements Exception {
  const NoteHasBuyersException();
}

const List<Color> _accentPalette = [
  Color(0xFF6366F1),
  Color(0xFF10B981),
  Color(0xFFEF4444),
  Color(0xFFF59E0B),
  Color(0xFF0EA5E9),
  Color(0xFF8B5CF6),
  Color(0xFFEC4899),
  Color(0xFF3B82F6),
];

/// Stable accent colour for a note based on its subject.
Color noteAccentFor(String subject) {
  final seed = subject.trim().toLowerCase();
  if (seed.isEmpty) return _accentPalette.first;
  return _accentPalette[seed.hashCode.abs() % _accentPalette.length];
}

/// Human friendly relative time (e.g. "2h ago").
String relativeTime(DateTime? time) {
  if (time == null) return 'just now';
  final diff = DateTime.now().difference(time.toLocal());
  if (diff.inSeconds < 60) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return '${(diff.inDays / 7).floor()}w ago';
}

/// Human friendly file size (e.g. "14 MB").
String formatBytes(int bytes) {
  if (bytes <= 0) return '';
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}

/// Coerces a Firestore value to [num] defensively.
///
/// Returns [int]/[double] as-is, parses numeric Strings (stripping `₹`,
/// commas and whitespace), and returns `null` for anything unparseable.
/// Used because legacy documents may store numeric fields as Strings.
num? toNum(Object? value) {
  if (value is num) return value;
  if (value is String) {
    final cleaned = value.replaceAll(RegExp(r'[₹,\s]'), '');
    return num.tryParse(cleaned);
  }
  return null;
}
