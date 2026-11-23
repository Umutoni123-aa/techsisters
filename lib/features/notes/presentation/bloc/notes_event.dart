part of 'notes_bloc.dart';

sealed class NotesEvent extends Equatable {
  const NotesEvent();

  @override
  List<Object?> get props => [];
}

/// Start listening to the signed-in user's notes (Read).
final class NotesSubscriptionRequested extends NotesEvent {
  const NotesSubscriptionRequested();
}

/// Create a new note, optionally linked to a lesson.
final class NoteAdded extends NotesEvent {
  const NoteAdded({required this.title, required this.content, this.lessonId});

  final String title;
  final String content;
  final String? lessonId;

  @override
  List<Object?> get props => [title, content, lessonId];
}

/// Save changes to an existing note (Update).
final class NoteUpdated extends NotesEvent {
  const NoteUpdated({
    required this.note,
    required this.title,
    required this.content,
  });

  final Note note;
  final String title;
  final String content;

  @override
  List<Object?> get props => [note, title, content];
}

/// Remove a note (Delete).
final class NoteDeleted extends NotesEvent {
  const NoteDeleted(this.note);

  final Note note;

  @override
  List<Object?> get props => [note];
}
