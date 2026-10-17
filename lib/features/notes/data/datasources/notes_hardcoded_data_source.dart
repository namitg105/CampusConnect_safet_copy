import '../../domain/entities/note_entities.dart';
import '../../domain/entities/note_inputs.dart';
import 'notes_data_source.dart';
import 'seed/my_notes_seed.dart';
import 'seed/note_details_seed.dart';
import 'seed/note_seed.dart' as note_data;

/// Demo implementation that reads the hardcoded seed files. Used when
/// `useHarcoded == true` so the app works fully offline.
class NotesHardcodedDataSource implements NotesDataSource {
  @override
  Future<List<Note>> getFeaturedNotes() async => note_data.featuredNotes;

  @override
  Future<List<Note>> getRecentNotes() async => note_data.recentNotes;

  @override
  Future<List<Note>> searchNotes(String query) async {
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
