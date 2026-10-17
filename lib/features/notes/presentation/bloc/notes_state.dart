part of 'notes_bloc.dart';

enum NotesOutcomeKind {
  uploaded,
  uploadFailed,
  storageCreditsEnded,
  deleteFailed,
  deleteBlockedByBuyers,
}

final class NotesOutcome extends Equatable {
  final NotesOutcomeKind kind;
  final String message;
  const NotesOutcome(this.kind, this.message);

  @override
  List<Object?> get props => [kind, message];
}

final class NotesState extends Equatable {
  final List<Note> featured;
  final List<Note> recent;
  final bool homeLoading;

  /// Set when (part of) the home failed to load; the page offers a retry.
  final String? homeError;

  final List<DashboardNote> myNotes;
  final List<DashboardNote> boughtNotes;
  final bool myNotesLoading;

  final bool uploading;

  /// Last upload/delete result; [outcomeId] makes repeats distinct.
  final NotesOutcome? outcome;
  final int outcomeId;

  const NotesState({
    this.featured = const [],
    this.recent = const [],
    this.homeLoading = true,
    this.homeError,
    this.myNotes = const [],
    this.boughtNotes = const [],
    this.myNotesLoading = true,
    this.uploading = false,
    this.outcome,
    this.outcomeId = 0,
  });

  NotesState copyWith({
    List<Note>? featured,
    List<Note>? recent,
    bool? homeLoading,
    String? Function()? homeError,
    List<DashboardNote>? myNotes,
    List<DashboardNote>? boughtNotes,
    bool? myNotesLoading,
    bool? uploading,
  }) {
    return NotesState(
      featured: featured ?? this.featured,
      recent: recent ?? this.recent,
      homeLoading: homeLoading ?? this.homeLoading,
      homeError: homeError != null ? homeError() : this.homeError,
      myNotes: myNotes ?? this.myNotes,
      boughtNotes: boughtNotes ?? this.boughtNotes,
      myNotesLoading: myNotesLoading ?? this.myNotesLoading,
      uploading: uploading ?? this.uploading,
      outcome: outcome,
      outcomeId: outcomeId,
    );
  }

  NotesState withOutcome(NotesOutcomeKind kind, String message) {
    return NotesState(
      featured: featured,
      recent: recent,
      homeLoading: homeLoading,
      homeError: homeError,
      myNotes: myNotes,
      boughtNotes: boughtNotes,
      myNotesLoading: myNotesLoading,
      uploading: uploading,
      outcome: NotesOutcome(kind, message),
      outcomeId: outcomeId + 1,
    );
  }

  @override
  List<Object?> get props => [
        featured,
        recent,
        homeLoading,
        homeError,
        myNotes,
        boughtNotes,
        myNotesLoading,
        uploading,
        outcome,
        outcomeId,
      ];
}
