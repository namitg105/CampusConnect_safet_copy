import 'dart:async';

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noteswap/core/usecase/usecase.dart';
import 'package:noteswap/features/notes/data/datasources/notes_data_source.dart';
import 'package:noteswap/features/notes/data/datasources/notes_hardcoded_data_source.dart';
import 'package:noteswap/features/notes/data/models/note_mappers.dart';
import 'package:noteswap/features/notes/data/repositories/notes_repository_impl.dart';
import 'package:noteswap/features/notes/domain/entities/note_entities.dart';
import 'package:noteswap/features/notes/domain/entities/note_inputs.dart';
import 'package:noteswap/features/notes/domain/repositories/notes_repository.dart';
import 'package:noteswap/features/notes/domain/usecases/notes_usecases.dart';
import 'package:noteswap/features/notes/presentation/bloc/note_detail_bloc.dart';
import 'package:noteswap/features/notes/presentation/bloc/note_search_bloc.dart';
import 'package:noteswap/features/notes/presentation/bloc/notes_bloc.dart';

Future<void> _settle() => Future<void>.delayed(const Duration(milliseconds: 10));

const _accent = Color(0xFF6366F1);
Note _note(String id) => Note(
    id: id, title: 'T$id', subject: 'S', author: 'A', uploadTime: '', downloads: 0, accent: _accent);
DashboardNote _dash(String id) => DashboardNote(
      id: id,
      title: 'T$id',
      subject: 'S',
      semester: '',
      uploadTime: '',
      price: 0,
      accent: _accent,
      authorId: 'me',
      buyerIds: const [],
      ratings: const [],
    );

const _upload = NoteUploadData(
  title: 'DSA',
  subject: 'DSA',
  courseCode: '',
  semester: '',
  description: '',
  price: 0,
  isFree: true,
  fileName: 'a.pdf',
  filePath: '/a.pdf',
  fileSize: 1,
);

/// Data source fake: each call can be made to throw.
class FakeSource implements NotesDataSource {
  Object? featuredError;
  Object? uploadError;
  Object? deleteError;
  Object? searchError;
  Object? purchaseError;
  final calls = <String>[];
  List<DashboardNote> mine = [_dash('1'), _dash('2')];
  final Map<String, Completer<List<Note>>> pendingSearches = {};

  @override
  Future<List<Note>> getFeaturedNotes() async {
    if (featuredError != null) throw featuredError!;
    return [_note('f')];
  }

  @override
  Future<List<Note>> getRecentNotes() async => [_note('r')];

  @override
  Future<List<Note>> searchNotes(String query) {
    calls.add('search:$query');
    if (searchError != null) return Future.error(searchError!);
    final c = Completer<List<Note>>();
    pendingSearches[query] = c;
    return c.future;
  }

  @override
  Future<NoteDetail> getNoteDetail(String noteId) async {
    calls.add('detail:$noteId');
    return NoteDetailBloc.unavailable.copyWith(isPurchased: calls.contains('buy:$noteId'));
  }

  @override
  Future<List<DashboardNote>> getMyNotes(String uid) async => mine;

  @override
  Future<List<DashboardNote>> getBoughtNotes(String uid) async => [];

  @override
  Future<void> uploadNote(NoteUploadData data, {required String uid}) async {
    calls.add('upload');
    if (uploadError != null) throw uploadError!;
  }

  @override
  Future<void> deleteNote(String noteId, {required String uid}) async {
    calls.add('delete:$noteId');
    if (deleteError != null) throw deleteError!;
    mine = mine.where((n) => n.id != noteId).toList();
  }

  @override
  Future<void> purchaseNote(String noteId, String buyerUid) async {
    if (purchaseError != null) throw purchaseError!;
    calls.add('buy:$noteId');
  }

  @override
  Future<void> recordDownload(String noteId, String uid) async =>
      calls.add('download:$noteId');

  @override
  Future<void> addReview(ReviewDraft draft) async {}
}

void main() {
  late FakeSource source;
  late NotesRepository repo;
  setUp(() {
    source = FakeSource();
    repo = NotesRepositoryImpl(source);
  });

  NotesBloc notesBloc() => NotesBloc(
        getHomeNotes: GetHomeNotes(repo),
        getMyNotes: GetMyNotes(repo),
        uploadNote: UploadNote(repo),
        deleteNote: DeleteNote(repo),
      );

  group('NotesRepositoryImpl error mapping', () {
    test('storage credits and buyers become typed failures', () async {
      source.uploadError = const StorageCreditException();
      final upload = await repo.uploadNote(_upload, uid: 'me');
      expect(upload.getLeft().toNullable(), isA<StorageCreditFailure>());

      source.deleteError = const NoteHasBuyersException();
      final delete = await repo.deleteNote('1', uid: 'me');
      expect(delete.getLeft().toNullable(), isA<NoteHasBuyersFailure>());
    });

    test('plain exceptions lose the "Exception: " prefix', () async {
      source.deleteError = Exception('You can only delete your own notes.');
      final r = await repo.deleteNote('1', uid: 'me');
      expect(r.getLeft().toNullable()!.message,
          'You can only delete your own notes.');
    });
  });

  group('NotesBloc', () {
    test('home: one failing section still shows the other + an error',
        () async {
      source.featuredError = Exception('index missing');
      final bloc = notesBloc()..add(const NotesHomeRequested());
      await _settle();
      expect(bloc.state.homeLoading, isFalse);
      expect(bloc.state.featured, isEmpty);
      expect(bloc.state.recent.single.id, 'r');
      expect(bloc.state.homeError, 'index missing');

      source.featuredError = null;
      bloc.add(const NotesHomeRequested());
      await _settle();
      expect(bloc.state.homeError, isNull);
      expect(bloc.state.featured.single.id, 'f');
      await bloc.close();
    });

    test('upload success reports and refreshes home + my notes', () async {
      final bloc = notesBloc()..add(const NoteUploadRequested(_upload, 'me'));
      await _settle();
      expect(bloc.state.uploading, isFalse);
      expect(bloc.state.outcome!.kind, NotesOutcomeKind.uploaded);
      expect(bloc.state.featured, isNotEmpty);
      expect(bloc.state.myNotes, hasLength(2));
      await bloc.close();
    });

    test('storage credits ended is its own outcome', () async {
      source.uploadError = const StorageCreditException();
      final bloc = notesBloc()..add(const NoteUploadRequested(_upload, 'me'));
      await _settle();
      expect(bloc.state.outcome!.kind, NotesOutcomeKind.storageCreditsEnded);
      expect(bloc.state.uploading, isFalse);
      await bloc.close();
    });

    test('delete removes the note; buyers block it', () async {
      final bloc = notesBloc()..add(const MyNotesRequested('me'));
      await _settle();
      bloc.add(NoteDeleteRequested(_dash('1'), 'me'));
      await _settle();
      expect(bloc.state.myNotes.map((n) => n.id), ['2']);

      source.deleteError = const NoteHasBuyersException();
      bloc.add(NoteDeleteRequested(_dash('2'), 'me'));
      await _settle();
      expect(bloc.state.outcome!.kind, NotesOutcomeKind.deleteBlockedByBuyers);
      expect(bloc.state.myNotes, hasLength(1));
      await bloc.close();
    });

    test('demo notes are deleted by title (they have no id)', () async {
      final bloc = notesBloc()
        ..add(NoteDeleteRequested(_dash(''), 'me'));
      await _settle();
      expect(source.calls, contains('delete:T'));
      await bloc.close();
    });
  });

  group('NoteSearchBloc', () {
    test('errors stop the spinner (fix)', () async {
      source.searchError = Exception('offline');
      final bloc = NoteSearchBloc(searchNotes: SearchNotes(repo))
        ..add(const NoteSearchRequested('x'));
      await _settle();
      expect(bloc.state.searching, isFalse);
      expect(bloc.state.error, 'offline');
      await bloc.close();
    });

    test('a slow older search cannot overwrite a newer one (fix)', () async {
      final bloc = NoteSearchBloc(searchNotes: SearchNotes(repo))
        ..add(const NoteSearchRequested('a'))
        ..add(const NoteSearchRequested('ab'));
      await _settle();
      source.pendingSearches['ab']!.complete([_note('new')]);
      await _settle();
      source.pendingSearches['a']!.complete([_note('old')]);
      await _settle();
      expect(bloc.state.results.single.id, 'new');
      expect(bloc.state.searching, isFalse);
      await bloc.close();
    });
  });

  group('NoteDetailBloc', () {
    NoteDetailBloc detailBloc() => NoteDetailBloc(
          getNoteDetail: GetNoteDetail(repo),
          purchaseNote: PurchaseNote(repo),
          recordDownload: RecordDownload(repo),
        );

    test('purchase reloads the detail and reports success', () async {
      final bloc = detailBloc()..add(NoteDetailRequested(_note('n')));
      await _settle();
      expect(bloc.state.detail!.isPurchased, isFalse);
      bloc.add(NotePurchaseRequested(_note('n'), 'me'));
      await _settle();
      expect(bloc.state.detail!.isPurchased, isTrue);
      expect(bloc.state.purchasing, isFalse);
      expect(bloc.state.message, 'Note purchased successfully');
      expect(bloc.state.messageIsError, isFalse);
      await bloc.close();
    });

    test('signed-out buy and failed buy show errors', () async {
      final bloc = detailBloc()..add(NotePurchaseRequested(_note('n'), ''));
      await _settle();
      expect(bloc.state.message, 'Please sign in to buy notes');

      source.purchaseError = Exception('You cannot buy your own note');
      bloc.add(NotePurchaseRequested(_note('n'), 'me'));
      await _settle();
      expect(bloc.state.message,
          'Could not purchase note: You cannot buy your own note');
      expect(bloc.state.messageIsError, isTrue);
      expect(bloc.state.messageId, 2);
      await bloc.close();
    });
  });

  test('hardcoded demo source still works offline', () async {
    final demo = NotesRepositoryImpl(NotesHardcodedDataSource());
    final home = await GetHomeNotes(demo)(const NoParams());
    expect(home.isRight(), isTrue);
  });
}
