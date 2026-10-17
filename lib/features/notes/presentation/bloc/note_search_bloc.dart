import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/note_entities.dart';
import '../../domain/usecases/notes_usecases.dart';

/// Search screen. Only the latest query's results are kept, so a slow
/// older response can never overwrite newer results.
class NoteSearchBloc extends Bloc<NoteSearchRequested, NoteSearchState> {
  final SearchNotes _search;
  int _latest = 0;

  NoteSearchBloc({required SearchNotes searchNotes})
      : _search = searchNotes,
        super(const NoteSearchState()) {
    on<NoteSearchRequested>(_onSearch);
  }

  Future<void> _onSearch(
    NoteSearchRequested event,
    Emitter<NoteSearchState> emit,
  ) async {
    final requestId = ++_latest;
    emit(NoteSearchState(results: state.results, searching: true));
    final result = await _search(event.query);
    if (requestId != _latest) return;
    // Fix: an error used to leave the spinner running forever.
    emit(NoteSearchState(
      results: result.getOrElse((_) => const []),
      searching: false,
      error: result.fold((f) => f.message, (_) => null),
    ));
  }
}

final class NoteSearchRequested extends Equatable {
  final String query;
  const NoteSearchRequested(this.query);

  @override
  List<Object?> get props => [query];
}

final class NoteSearchState extends Equatable {
  final List<Note> results;
  final bool searching;
  final String? error;

  const NoteSearchState({
    this.results = const [],
    this.searching = false,
    this.error,
  });

  @override
  List<Object?> get props => [results, searching, error];
}
