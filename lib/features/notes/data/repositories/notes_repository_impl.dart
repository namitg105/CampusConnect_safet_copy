import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/note_entities.dart';
import '../../domain/entities/note_inputs.dart';
import '../../domain/repositories/notes_repository.dart';
import '../datasources/notes_data_source.dart';
import '../models/note_mappers.dart';

class NotesRepositoryImpl implements NotesRepository {
  final NotesDataSource source;
  const NotesRepositoryImpl(this.source);

  /// Maps data-layer exceptions to domain failures. The notes data sources
  /// throw plain `Exception('...')` messages, so the "Exception: " prefix
  /// is removed before showing them.
  Future<Either<Failure, T>> _run<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on StorageCreditException catch (e) {
      return Left(StorageCreditFailure(e.message));
    } on NoteHasBuyersException {
      return const Left(NoteHasBuyersFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, List<Note>>> getFeaturedNotes() =>
      _run(source.getFeaturedNotes);

  @override
  Future<Either<Failure, List<Note>>> getRecentNotes() =>
      _run(source.getRecentNotes);

  @override
  Future<Either<Failure, List<Note>>> searchNotes(String query) =>
      _run(() => source.searchNotes(query));

  @override
  Future<Either<Failure, NoteDetail>> getNoteDetail(String noteKey) =>
      _run(() => source.getNoteDetail(noteKey));

  @override
  Future<Either<Failure, List<DashboardNote>>> getMyNotes(String uid) =>
      _run(() => source.getMyNotes(uid));

  @override
  Future<Either<Failure, List<DashboardNote>>> getBoughtNotes(String uid) =>
      _run(() => source.getBoughtNotes(uid));

  @override
  Future<Either<Failure, void>> uploadNote(NoteUploadData data,
          {required String uid}) =>
      _run(() => source.uploadNote(data, uid: uid));

  @override
  Future<Either<Failure, void>> deleteNote(String noteId,
          {required String uid}) =>
      _run(() => source.deleteNote(noteId, uid: uid));

  @override
  Future<Either<Failure, void>> purchaseNote(String noteKey, String buyerUid) =>
      _run(() => source.purchaseNote(noteKey, buyerUid));

  @override
  Future<Either<Failure, void>> recordDownload(String noteId, String uid) =>
      _run(() => source.recordDownload(noteId, uid));
}
