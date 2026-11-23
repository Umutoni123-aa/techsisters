import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:techsisters/features/notes/data/models/note_model.dart';

void main() {
  final created = DateTime(2026, 11, 1, 9, 30);
  final updated = DateTime(2026, 11, 2, 14);

  group('NoteModel', () {
    test('fromMap reads every Firestore field', () {
      final model = NoteModel.fromMap('note-1', {
        'userId': 'user-1',
        'lessonId': 'lesson-2',
        'title': 'Lecture notes',
        'content': 'Clean Architecture layers',
        'createdAt': Timestamp.fromDate(created),
        'updatedAt': Timestamp.fromDate(updated),
      });

      expect(model.id, 'note-1');
      expect(model.userId, 'user-1');
      expect(model.lessonId, 'lesson-2');
      expect(model.title, 'Lecture notes');
      expect(model.content, 'Clean Architecture layers');
      expect(model.createdAt, created);
      expect(model.updatedAt, updated);
    });

    test('fromMap uses safe defaults for missing fields', () {
      final model = NoteModel.fromMap('note-2', {});

      expect(model.userId, '');
      expect(model.lessonId, isNull);
      expect(model.title, '');
      expect(model.content, '');
    });

    test('toMap writes the same field names as the ERD', () {
      final model = NoteModel(
        id: 'note-1',
        userId: 'user-1',
        title: 'Lecture notes',
        content: 'BLoC',
        createdAt: created,
        updatedAt: updated,
      );

      expect(model.toMap(), {
        'userId': 'user-1',
        'lessonId': null,
        'title': 'Lecture notes',
        'content': 'BLoC',
        'createdAt': Timestamp.fromDate(created),
        'updatedAt': Timestamp.fromDate(updated),
      });
    });
  });
}
