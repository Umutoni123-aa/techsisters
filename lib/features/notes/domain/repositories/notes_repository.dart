import '../entities/note.dart';

/// Contract for storing notes. The domain and presentation layers only know
/// this interface, so tests can swap in a mock instead of Firestore.
abstract class NotesRepository {
  /// Live list of the learner's notes, newest first. Emits again after every
  /// create, update or delete, so the UI updates without a refresh.
  Stream<List<Note>> watchNotes(String userId);

  Future<void> addNote({
    required String userId,
    String? lessonId,
    required String title,
    required String content,
  });

  Future<void> updateNote(Note note);

  Future<void> deleteNote(String noteId);
}

/// Thrown by the repository when a database call fails. [message] is
/// written for the learner and is safe to show in a snackbar.
class NotesException implements Exception {
  const NotesException(this.message);

  final String message;

  @override
  String toString() => 'NotesException: $message';
}
