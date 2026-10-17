import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/note_entities.dart';
import '../entities/note_inputs.dart';

/// Firebase Storage refused the upload because its quota/credits ran out.
class StorageCreditFailure extends Failure {
  const StorageCreditFailure([super.message = 'Fire storage credits ended']);
}

/// The note cannot be deleted because someone already bought it.
class NoteHasBuyersFailure extends Failure {
  const NoteHasBuyersFailure([super.message = 'buys exists at this notes']);
}

/// NoteSwap marketplace operations. Implemented in the data layer.
abstract interface class NotesRepository {
  Future<Either<Failure, List<Note>>> getFeaturedNotes();

  Future<Either<Failure, List<Note>>> getRecentNotes();

  Future<Either<Failure, List<Note>>> searchNotes(String query);

  /// [noteKey] is the document id (or the title for demo notes).
  Future<Either<Failure, NoteDetail>> getNoteDetail(String noteKey);

  Future<Either<Failure, List<DashboardNote>>> getMyNotes(String uid);

  Future<Either<Failure, List<DashboardNote>>> getBoughtNotes(String uid);

  /// Fails with [StorageCreditFailure] when Storage is out of credits.
  Future<Either<Failure, void>> uploadNote(NoteUploadData data,
      {required String uid});

  /// Fails with [NoteHasBuyersFailure] when the note was already bought.
  Future<Either<Failure, void>> deleteNote(String noteId,
      {required String uid});

  Future<Either<Failure, void>> purchaseNote(String noteKey, String buyerUid);

  /// Best-effort download counter (never fails the caller).
  Future<Either<Failure, void>> recordDownload(String noteId, String uid);
}
