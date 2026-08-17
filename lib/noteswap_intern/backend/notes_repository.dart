import '../my_notes_data.dart';
import '../note_data.dart';
import '../note_details_data.dart';
import 'note_models.dart';

/// Abstraction over the noteswap data sources.
///
/// Two implementations exist:
///  * [HardcodedNotesRepository] -> reads the demo seed files.
///  * FirestoreNotesRepository  -> reads/writes Firestore + Firebase Storage.
///
/// Pick the active one through `getNotesRepo()` in `notes_repo_factory.dart`,
/// which honours the `useHarcoded` switch.
abstract class NotesRepository {
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
