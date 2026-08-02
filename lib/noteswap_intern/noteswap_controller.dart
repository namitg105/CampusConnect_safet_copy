import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import 'backend/note_models.dart';
import 'backend/notes_repo_factory.dart';
import 'backend/notes_repository.dart';
import 'backend/switch_hardcode_backend.dart';
import 'my_notes_data.dart';
import 'note_data.dart';
import 'note_details_data.dart';

/// GetX controller that sits between the noteswap screens and the active
/// [NotesRepository] (hardcoded or Firestore depending on `useHarcoded`).
class NoteswapController extends GetxController {
  static NoteswapController get instance => Get.find();

  final NotesRepository _repo = getNotesRepo();

  // Home page (featured + recently added).
  final RxList<Note> featuredNotes = RxList<Note>([]);
  final RxList<Note> recentNotes = RxList<Note>([]);
  final RxBool homeLoading = RxBool(true);
  final Rx<Object?> homeError = Rx<Object?>(null);

  // My notes dashboard.
  final RxList<DashboardNote> myNotes = RxList<DashboardNote>([]);
  final RxList<DashboardNote> boughtNotes = RxList<DashboardNote>([]);
  final RxBool notesLoading = RxBool(true);

  Future<void> loadHome() async {
    homeLoading.value = true;
    // One query failing (e.g. a transient Firestore error) must not blank the
    // whole home page: each section is loaded independently and the error is
    // surfaced through [homeError].
    Object? error;
    try {
      try {
        final featured = await _repo.getFeaturedNotes();
        featuredNotes.assignAll(featured);
      } catch (e) {
        error = e;
      }
      try {
        final recent = await _repo.getRecentNotes();
        recentNotes.assignAll(recent);
      } catch (e) {
        error ??= e;
      }
    } finally {
      homeLoading.value = false;
    }
    homeError.value = error;
  }

  Future<List<Note>> search(String query) async {
    try {
      return await _repo.searchNotes(query);
    } finally {
      // no-op; kept for symmetry with the resilience pattern
    }
  }

  /// Resolves the detail. Hardcoded notes use their title as the key,
  /// Firestore notes use their document id.
  Future<NoteDetail> getDetail(Note note) {
    return _repo.getNoteDetail(note.id.isEmpty ? note.title : note.id);
  }

  Future<void> loadMyNotes(String uid) async {
    notesLoading.value = true;
    try {
      final results = await Future.wait([
        _repo.getMyNotes(uid),
        _repo.getBoughtNotes(uid),
      ]);
      myNotes.assignAll(results[0]);
      boughtNotes.assignAll(results[1]);
    } finally {
      notesLoading.value = false;
    }
  }

  Future<void> refreshMyNotes() {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    return loadMyNotes(uid);
  }

  Future<void> deleteNote(String noteId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    await _repo.deleteNote(noteId, uid: uid);
    if (!useHarcoded) await refreshMyNotes();
  }

  Future<void> purchase(Note note) async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    await _repo.purchaseNote(note.id.isEmpty ? note.title : note.id, uid);
  }

  /// Registers a download on Firestore for purchased/owned notes.
  Future<void> recordDownload(NoteDetail detail) async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (detail.noteId.isEmpty) return;
    await _repo.recordDownload(detail.noteId, uid);
  }

  Future<void> upload(NoteUploadData data) async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    await _repo.uploadNote(data, uid: uid);
    await loadHome();
    if (!useHarcoded && uid.isNotEmpty) await loadMyNotes(uid);
  }
}
