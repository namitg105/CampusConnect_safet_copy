import '../my_notes_data.dart';
import '../note_data.dart' as note_data;
import '../note_details_data.dart';
import 'note_models.dart';
import 'notes_repository.dart';

/// Demo implementation that reads the hardcoded seed files. Used when
/// `useHarcoded == true` so the app works fully offline.
class HardcodedNotesRepository implements NotesRepository {
  @override
  Future<List<note_data.Note>> getFeaturedNotes() async => note_data.featuredNotes;

  @override
  Future<List<note_data.Note>> getRecentNotes() async => note_data.recentNotes;

  @override
  Future<List<note_data.Note>> searchNotes(String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return note_data.searchNotes;
    return note_data.searchNotes.where((note) {
      return note.title.toLowerCase().contains(q) ||
          note.subject.toLowerCase().contains(q) ||
          note.author.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Future<NoteDetail> getNoteDetail(String noteId) async {
    return noteDetails[noteId] ?? noteDetails.values.first;
  }

  @override
  Future<List<DashboardNote>> getMyNotes(String uid) async {
    return myNotesSeed
        .map((n) => n.copyWith(id: n.title, authorId: uid))
        .toList();
  }

  @override
  Future<List<DashboardNote>> getBoughtNotes(String uid) async {
    return boughtNotesSeed
        .map((n) => n.copyWith(id: n.title, buyerIds: [...n.buyerIds, uid]))
        .toList();
  }

  @override
  Future<void> uploadNote(NoteUploadData data, {required String uid}) async {}

  @override
  Future<void> deleteNote(String noteId, {required String uid}) async {}

  @override
  Future<void> purchaseNote(String noteId, String buyerUid) async {}

  @override
  Future<void> recordDownload(String noteId, String uid) async {}

  @override
  Future<void> addReview(ReviewDraft draft) async {}
}
