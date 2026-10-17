import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/note_entities.dart';
import '../entities/note_inputs.dart';
import '../repositories/notes_repository.dart';

/// Featured + recently added notes for the Notes home.
class HomeNotes {
  final List<Note> featured;
  final List<Note> recent;

  /// Set when one section failed; the other section is still shown.
  final Failure? partialFailure;

  const HomeNotes({
    required this.featured,
    required this.recent,
    this.partialFailure,
  });
}

/// Loads both home sections independently: one failing section must not
/// blank the whole page (same rule as before the refactor).
class GetHomeNotes implements UseCase<HomeNotes, NoParams> {
  final NotesRepository repo;
  const GetHomeNotes(this.repo);

  @override
  Future<Either<Failure, HomeNotes>> call(NoParams params) async {
    final featured = await repo.getFeaturedNotes();
    final recent = await repo.getRecentNotes();
    return Right(HomeNotes(
      featured: featured.getOrElse((_) => const []),
      recent: recent.getOrElse((_) => const []),
      partialFailure: featured.getLeft().toNullable() ??
          recent.getLeft().toNullable(),
    ));
  }
}

/// Params: the search text.
class SearchNotes implements UseCase<List<Note>, String> {
  final NotesRepository repo;
  const SearchNotes(this.repo);

  @override
  Future<Either<Failure, List<Note>>> call(String query) =>
      repo.searchNotes(query);
}

/// Hardcoded notes use their title as the key, Firestore notes their id.
String noteKeyOf(Note note) => note.id.isEmpty ? note.title : note.id;

/// Params: the note tapped in a list.
class GetNoteDetail implements UseCase<NoteDetail, Note> {
  final NotesRepository repo;
  const GetNoteDetail(this.repo);

  @override
  Future<Either<Failure, NoteDetail>> call(Note note) =>
      repo.getNoteDetail(noteKeyOf(note));
}

/// The user's own uploads and the notes they bought.
class MyNotes {
  final List<DashboardNote> uploaded;
  final List<DashboardNote> bought;
  const MyNotes({required this.uploaded, required this.bought});
}

/// Params: the user's uid.
class GetMyNotes implements UseCase<MyNotes, String> {
  final NotesRepository repo;
  const GetMyNotes(this.repo);

  @override
  Future<Either<Failure, MyNotes>> call(String uid) async {
    final results =
        await Future.wait([repo.getMyNotes(uid), repo.getBoughtNotes(uid)]);
    return results[0].flatMap((uploaded) => results[1]
        .map((bought) => MyNotes(uploaded: uploaded, bought: bought)));
  }
}

class NoteUserParams<T> {
  final T note;
  final String uid;
  const NoteUserParams(this.note, this.uid);
}

class UploadNote implements UseCase<void, NoteUserParams<NoteUploadData>> {
  final NotesRepository repo;
  const UploadNote(this.repo);

  @override
  Future<Either<Failure, void>> call(NoteUserParams<NoteUploadData> p) =>
      repo.uploadNote(p.note, uid: p.uid);
}

/// Params: the note key (see [noteKeyOf]) and the author's uid.
class DeleteNote implements UseCase<void, NoteUserParams<String>> {
  final NotesRepository repo;
  const DeleteNote(this.repo);

  @override
  Future<Either<Failure, void>> call(NoteUserParams<String> p) =>
      repo.deleteNote(p.note, uid: p.uid);
}

class PurchaseNote implements UseCase<void, NoteUserParams<Note>> {
  final NotesRepository repo;
  const PurchaseNote(this.repo);

  @override
  Future<Either<Failure, void>> call(NoteUserParams<Note> p) =>
      repo.purchaseNote(noteKeyOf(p.note), p.uid);
}

class RecordDownload implements UseCase<void, NoteUserParams<NoteDetail>> {
  final NotesRepository repo;
  const RecordDownload(this.repo);

  @override
  Future<Either<Failure, void>> call(NoteUserParams<NoteDetail> p) async {
    if (p.note.noteId.isEmpty) return const Right(null);
    return repo.recordDownload(p.note.noteId, p.uid);
  }
}
