part of 'notes_bloc.dart';

sealed class NotesEvent extends Equatable {
  const NotesEvent();

  @override
  List<Object?> get props => [];
}

/// Load (or retry) featured + recently added notes.
final class NotesHomeRequested extends NotesEvent {
  const NotesHomeRequested();
}

/// Load the user's uploads and purchases.
final class MyNotesRequested extends NotesEvent {
  final String uid;
  const MyNotesRequested(this.uid);

  @override
  List<Object?> get props => [uid];
}

final class NoteUploadRequested extends NotesEvent {
  final NoteUploadData data;
  final String uid;
  const NoteUploadRequested(this.data, this.uid);

  @override
  List<Object?> get props => [data.filePath, data.title, uid];
}

final class NoteDeleteRequested extends NotesEvent {
  final DashboardNote note;
  final String uid;
  const NoteDeleteRequested(this.note, this.uid);

  @override
  List<Object?> get props => [note.id, note.title, uid];
}

/// Logout: forget the previous user's notes.
final class NotesCleared extends NotesEvent {
  const NotesCleared();
}
