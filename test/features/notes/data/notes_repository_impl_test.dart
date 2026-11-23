import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:techsisters/features/notes/data/datasources/notes_remote_datasource.dart';
import 'package:techsisters/features/notes/data/repositories/notes_repository_impl.dart';

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
}
