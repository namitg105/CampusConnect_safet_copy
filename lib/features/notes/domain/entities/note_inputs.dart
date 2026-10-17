/// Inputs the Notes screens send to the domain layer.

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
