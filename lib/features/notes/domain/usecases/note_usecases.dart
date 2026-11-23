import '../entities/note.dart';
import '../repositories/notes_repository.dart';

// One small class per action, following the same pattern as the
// authentication feature's use cases. NotesBloc depends on these instead of
// calling the repository directly.

/// Read: listen to the learner's notes.
class WatchNotesUseCase {
  const WatchNotesUseCase(this.repository);

  final NotesRepository repository;

  Stream<List<Note>> call(String userId) => repository.watchNotes(userId);
}

/// Create: save a new note, optionally linked to a lesson.
class AddNoteUseCase {
  const AddNoteUseCase(this.repository);

  final NotesRepository repository;

  Future<void> call({
    required String userId,
    String? lessonId,
    required String title,
    required String content,
  }) {
    return repository.addNote(
      userId: userId,
      lessonId: lessonId,
      title: title.trim(),
      content: content.trim(),
    );
  }
}

/// Update: change the title and content of an existing note.
class UpdateNoteUseCase {
  const UpdateNoteUseCase(this.repository);

  final NotesRepository repository;

  Future<void> call(
    Note note, {
    required String title,
    required String content,
  }) {
    return repository.updateNote(
      note.copyWith(title: title.trim(), content: content.trim()),
    );
  }
}

/// Delete: remove a note.
class DeleteNoteUseCase {
  const DeleteNoteUseCase(this.repository);

  final NotesRepository repository;

  Future<void> call(Note note) => repository.deleteNote(note.id);
}
