import 'firestore_notes_repository.dart';
import 'hardcoded_notes_repository.dart';
import 'notes_repository.dart';
import 'switch_hardcode_backend.dart';

/// Returns the active [NotesRepository] based on the `useHarcoded` switch.
NotesRepository getNotesRepo() {
  return useHarcoded
      ? HardcodedNotesRepository()
      : FirestoreNotesRepository();
}
