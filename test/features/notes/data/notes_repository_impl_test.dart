import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:techsisters/features/notes/data/datasources/notes_remote_datasource.dart';
import 'package:techsisters/features/notes/data/repositories/notes_repository_impl.dart';
import 'package:techsisters/features/notes/domain/repositories/notes_repository.dart';

class MockNotesRemoteDataSource extends Mock implements NotesRemoteDataSource {}

void main() {
  late FakeFirebaseFirestore firestore;
  late NotesRepositoryImpl repository;

  setUp(() {
    // An in-memory Firestore, so these tests never touch the real database.
    firestore = FakeFirebaseFirestore();
    repository = NotesRepositoryImpl(
      dataSource: NotesRemoteDataSource(firestore: firestore),
    );
  });

  test('addNote saves every ERD field and only the owner sees it', () async {
    await repository.addNote(
      userId: 'user-1',
      lessonId: 'lesson-1',
      title: 'Variables',
      content: 'var, final and const',
    );
    await repository.addNote(
      userId: 'user-2',
      title: 'Someone else',
      content: '',
    );

    final notes = await repository.watchNotes('user-1').first;
    expect(notes, hasLength(1));
    expect(notes.single.title, 'Variables');
    expect(notes.single.lessonId, 'lesson-1');

    final saved = (await firestore.collection('notes').get()).docs.first;
    expect(
      saved.data().keys,
      unorderedEquals([
        'userId',
        'lessonId',
        'title',
        'content',
        'createdAt',
        'updatedAt',
      ]),
    );
  });

  test('updateNote changes the title and content', () async {
    await repository.addNote(userId: 'user-1', title: 'Draft', content: '');
    final original = (await repository.watchNotes('user-1').first).single;

    await repository.updateNote(
      original.copyWith(title: 'Final', content: 'Done'),
    );

    final updated = (await repository.watchNotes('user-1').first).single;
    expect(updated.id, original.id);
    expect(updated.title, 'Final');
    expect(updated.content, 'Done');
  });

  test('deleteNote removes the note', () async {
    await repository.addNote(userId: 'user-1', title: 'Temp', content: '');
    final note = (await repository.watchNotes('user-1').first).single;

    await repository.deleteNote(note.id);

    expect(await repository.watchNotes('user-1').first, isEmpty);
  });

  test('a missing index becomes a friendly "still being set up" message', () {
    final dataSource = MockNotesRemoteDataSource();
    when(() => dataSource.watchNotes('user-1')).thenAnswer(
      (_) => Stream.error(
        FirebaseException(
          plugin: 'cloud_firestore',
          code: 'failed-precondition',
          message: 'The query requires an index.',
        ),
      ),
    );

    expect(
      NotesRepositoryImpl(dataSource: dataSource).watchNotes('user-1'),
      emitsError(
        isA<NotesException>().having(
          (e) => e.message,
          'message',
          'Your notes list is still being set up. '
              'Please try again in a few minutes.',
        ),
      ),
    );
  });
}
