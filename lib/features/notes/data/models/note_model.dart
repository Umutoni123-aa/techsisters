import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/note.dart';

/// Converts between Firestore documents and the [Note] entity.
///
/// Field names match the ERD exactly:
/// notes/{noteId}: userId, lessonId, title, content, createdAt, updatedAt
class NoteModel extends Note {
  const NoteModel({
    required super.id,
    required super.userId,
    super.lessonId,
    required super.title,
    required super.content,
    required super.createdAt,
    required super.updatedAt,
  });

  factory NoteModel.fromMap(String id, Map<String, dynamic> map) {
    return NoteModel(
      id: id,
      userId: map['userId'] as String? ?? '',
      lessonId: map['lessonId'] as String?,
      title: map['title'] as String? ?? '',
      content: map['content'] as String? ?? '',
      createdAt: _toDateTime(map['createdAt']),
      updatedAt: _toDateTime(map['updatedAt']),
    );
  }

  /// Right after a write, Firestore reports a server timestamp as `null`
  /// until the server confirms it. Using "now" in that moment keeps the new
  /// note at the top of the list instead of jumping around.
  static DateTime _toDateTime(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'lessonId': lessonId,
      'title': title,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
