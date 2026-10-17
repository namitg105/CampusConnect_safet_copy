import '../../domain/entities/note_entities.dart';
import '../../domain/entities/note_inputs.dart';

/// Raw access to notes data (throws on failure).
///
/// Two implementations exist:
///  * [NotesHardcodedDataSource] -> the demo seed files (offline demo).
///  * [NotesFirestoreDataSource]  -> Firestore + Firebase Storage.
///
/// DI picks one with the `useHarcoded` switch.
abstract interface class NotesDataSource {
  Future<List<Note>> getFeaturedNotes();

  Future<List<Note>> getRecentNotes();

  Future<List<Note>> searchNotes(String query);

  Future<NoteDetail> getNoteDetail(String noteId);

  Future<List<DashboardNote>> getMyNotes(String uid);

  Future<List<DashboardNote>> getBoughtNotes(String uid);

  Future<void> uploadNote(NoteUploadData data, {required String uid});

  Future<void> deleteNote(String noteId, {required String uid});

  Future<void> purchaseNote(String noteId, String buyerUid);

  /// Increments the note's download counter. Only the owner or a buyer of the
  /// note may trigger it (best-effort, fails silently when rules block it).
  Future<void> recordDownload(String noteId, String uid);

  Future<void> addReview(ReviewDraft draft);
}
