import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/note_entities.dart';
import '../../domain/entities/note_inputs.dart';
import '../../domain/repositories/notes_repository.dart';
import '../../domain/usecases/notes_usecases.dart';

part 'notes_event.dart';
part 'notes_state.dart';

/// App-wide NoteSwap data: the Notes home, "My notes", upload and delete.
/// Replaces the permanent GetX `NoteswapController`.
class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final GetHomeNotes _getHome;
  final GetMyNotes _getMyNotes;
  final UploadNote _upload;
  final DeleteNote _delete;

  NotesBloc({
    required GetHomeNotes getHomeNotes,
    required GetMyNotes getMyNotes,
    required UploadNote uploadNote,
    required DeleteNote deleteNote,
  })  : _getHome = getHomeNotes,
        _getMyNotes = getMyNotes,
        _upload = uploadNote,
        _delete = deleteNote,
        super(const NotesState()) {
    on<NotesHomeRequested>((event, emit) => _loadHome(emit));
    on<MyNotesRequested>((event, emit) => _loadMyNotes(event.uid, emit));
    on<NoteUploadRequested>(_onUpload);
    on<NoteDeleteRequested>(_onDelete);
    on<NotesCleared>((event, emit) => emit(const NotesState()));
  }

  Future<void> _loadHome(Emitter<NotesState> emit) async {
    emit(state.copyWith(homeLoading: true));
    final result = await _getHome(const NoParams());
    result.fold(
      (failure) => emit(state.copyWith(
          homeLoading: false, homeError: () => failure.message)),
      (home) => emit(state.copyWith(
        homeLoading: false,
        featured: home.featured,
        recent: home.recent,
        homeError: () => home.partialFailure?.message,
      )),
    );
  }

  Future<void> _loadMyNotes(String uid, Emitter<NotesState> emit) async {
    emit(state.copyWith(myNotesLoading: true));
    final result = await _getMyNotes(uid);
    result.fold(
      // Before: a failure just stopped the spinner; lists were kept.
      (_) => emit(state.copyWith(myNotesLoading: false)),
      (notes) => emit(state.copyWith(
        myNotesLoading: false,
        myNotes: notes.uploaded,
        boughtNotes: notes.bought,
      )),
    );
  }

  Future<void> _onUpload(
    NoteUploadRequested event,
    Emitter<NotesState> emit,
  ) async {
    emit(state.copyWith(uploading: true));
    final result = await _upload(NoteUserParams(event.data, event.uid));
    await result.fold(
      (failure) async {
        emit(state.copyWith(uploading: false).withOutcome(
              failure is StorageCreditFailure
                  ? NotesOutcomeKind.storageCreditsEnded
                  : NotesOutcomeKind.uploadFailed,
              failure.message,
            ));
      },
      (_) async {
        emit(state.copyWith(uploading: false)
            .withOutcome(NotesOutcomeKind.uploaded, 'Note uploaded successfully'));
        // The new note shows on the home and in "My notes".
        await _loadHome(emit);
        if (event.uid.isNotEmpty) await _loadMyNotes(event.uid, emit);
      },
    );
  }

  Future<void> _onDelete(
    NoteDeleteRequested event,
    Emitter<NotesState> emit,
  ) async {
    final key = event.note.id.isEmpty ? event.note.title : event.note.id;
    final result = await _delete(NoteUserParams(key, event.uid));
    await result.fold(
      (failure) async => emit(state.withOutcome(
        failure is NoteHasBuyersFailure
            ? NotesOutcomeKind.deleteBlockedByBuyers
            : NotesOutcomeKind.deleteFailed,
        failure.message,
      )),
      (_) async {
        bool keep(DashboardNote n) => (n.id.isEmpty ? n.title : n.id) != key;
        emit(state.copyWith(
          myNotes: state.myNotes.where(keep).toList(),
          boughtNotes: state.boughtNotes.where(keep).toList(),
        ));
        await _loadMyNotes(event.uid, emit);
      },
    );
  }
}
