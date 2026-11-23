import 'package:equatable/equatable.dart';

/// A personal note written by a learner.
///
/// Matches the `notes` entity in the group ERD (docs/erd.png). This is the
/// domain entity, so it has no Firebase types in it.
class Note extends Equatable {
  const Note({
    required this.id,
    required this.userId,
    this.lessonId,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Firestore document ID (PK `noteId` in the ERD).
  final String id;

  /// UID of the learner who wrote the note (FK to `users`).
  final String userId;

  /// Lesson the note is about (optional FK to `lessons`). Null for a general
  /// note that is not linked to a lesson.
  final String? lessonId;

  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note copyWith({String? title, String? content, DateTime? updatedAt}) {
    return Note(
      id: id,
      userId: userId,
      lessonId: lessonId,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    lessonId,
    title,
    content,
    createdAt,
    updatedAt,
  ];
}
