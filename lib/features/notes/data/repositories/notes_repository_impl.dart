import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/note.dart';
import '../../domain/repositories/notes_repository.dart';
import '../datasources/notes_remote_datasource.dart';

/// Implements [NotesRepository] using [NotesRemoteDataSource], and turns
/// Firebase errors into [NotesException]s with messages for the learner.
class NotesRepositoryImpl implements NotesRepository {
  NotesRepositoryImpl({required this._dataSource});

  final NotesRemoteDataSource _dataSource;

  @override
  Stream<List<Note>> watchNotes(String userId) {
    return _dataSource
        .watchNotes(userId)
        .handleError((Object error) => throw _toNotesException(error));
  }

  @override
  Future<void> addNote({
    required String userId,
    String? lessonId,
    required String title,
    required String content,
  }) {
    return _run(
      () => _dataSource.addNote(
        userId: userId,
        lessonId: lessonId,
        title: title,
        content: content,
      ),
    );
  }

  @override
  Future<void> updateNote(Note note) {
    return _run(
      () => _dataSource.updateNote(
        noteId: note.id,
        title: note.title,
        content: note.content,
      ),
    );
  }

  @override
  Future<void> deleteNote(String noteId) {
    return _run(() => _dataSource.deleteNote(noteId));
  }

  /// Runs a data source call and rethrows any failure as a [NotesException].
  Future<void> _run(Future<void> Function() action) async {
    try {
      await action();
    } catch (error) {
      throw _toNotesException(error);
    }
  }

  NotesException _toNotesException(Object error) {
    if (error is NotesException) return error;
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return const NotesException(
            "You don't have permission to change this note.",
          );
        case 'unavailable':
          return const NotesException(
            'You seem to be offline. Check your connection and try again.',
          );
        case 'not-found':
          return const NotesException('This note no longer exists.');
      }
    }
    return const NotesException('Something went wrong. Please try again.');
  }
}
