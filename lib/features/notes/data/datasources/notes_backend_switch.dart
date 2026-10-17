/// CENTRAL SWITCH between the hardcoded demo data and the real Firebase
/// backend for the noteswap pages.
///
/// * `true`  -> upload/notes/my-notes pages read from the hardcoded seed files
///              (`note_data.dart`, `note_details_data.dart`, `my_notes_data.dart`)
///              so the app runs fully offline as a demo.
/// * `false` -> the pages talk to Firestore + Firebase Storage.
///
/// Change this single boolean to flip the whole noteswap module.
const bool useHarcoded = false;
