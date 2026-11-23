import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:techsisters/features/notes/domain/entities/note.dart';
import 'package:techsisters/features/notes/domain/repositories/notes_repository.dart';
import 'package:techsisters/features/notes/presentation/bloc/notes_bloc.dart';

class MockNotesRepository extends Mock implements NotesRepository {}

void main() {
  const userId = 'user-1';
  final note = Note(
    id: 'note-1',
    userId: userId,
    title: 'Revision',
    content: 'Chapter 4',
    createdAt: DateTime(2026, 11, 1),
    updatedAt: DateTime(2026, 11, 1),
  );

  late MockNotesRepository repository;

  setUpAll(() => registerFallbackValue(note));

  setUp(() => repository = MockNotesRepository());

  // Real use cases on top of a mock repository, so the use cases are
  // tested together with the BLoC.
  NotesBloc buildBloc() =>
      NotesBloc.fromRepository(repository: repository, userId: userId);

  void stubAddNote() {
    when(
      () => repository.addNote(
        userId: any(named: 'userId'),
        lessonId: any(named: 'lessonId'),
        title: any(named: 'title'),
        content: any(named: 'content'),
      ),
    ).thenAnswer((_) async {});
  }

  test('starts in the initial state', () {
    expect(buildBloc().state, const NotesState());
  });

  group('NotesSubscriptionRequested', () {
    blocTest<NotesBloc, NotesState>(
      'emits loading, then the notes from the repository',
      setUp: () =>
          when(() => repository.watchNotes(userId))
              .thenAnswer((_) => Stream.value([note])),
      build: buildBloc,
      act: (bloc) => bloc.add(const NotesSubscriptionRequested()),
      expect: () => [
        const NotesState(status: NotesStatus.loading),
        NotesState(status: NotesStatus.success, notes: [note]),
      ],
    );

    blocTest<NotesBloc, NotesState>(
      'emits failure with a message when loading fails',
      setUp: () => when(() => repository.watchNotes(userId)).thenAnswer(
        (_) => Stream.error(const NotesException('Could not load notes')),
      ),
      build: buildBloc,
      act: (bloc) => bloc.add(const NotesSubscriptionRequested()),
      expect: () => [
        const NotesState(status: NotesStatus.loading),
        const NotesState(
          status: NotesStatus.failure,
          message: 'Could not load notes',
          messageType: NotesMessageType.error,
        ),
      ],
    );
  });

  group('NoteAdded', () {
    blocTest<NotesBloc, NotesState>(
      'saves a trimmed note and reports success',
      setUp: stubAddNote,
      build: buildBloc,
      act: (bloc) =>
          bloc.add(const NoteAdded(title: '  New  ', content: 'Body ')),
      expect: () => [const NotesState(message: 'Note saved')],
      verify: (_) => verify(
        () => repository.addNote(
          userId: userId,
          lessonId: null,
          title: 'New',
          content: 'Body',
        ),
      ).called(1),
    );

    blocTest<NotesBloc, NotesState>(
      'links the note to a lesson when a lessonId is given',
      setUp: stubAddNote,
      build: buildBloc,
      act: (bloc) => bloc.add(
        const NoteAdded(title: 'Loops', content: '', lessonId: 'lesson-3'),
      ),
      verify: (_) => verify(
        () => repository.addNote(
          userId: userId,
          lessonId: 'lesson-3',
          title: 'Loops',
          content: '',
        ),
      ).called(1),
    );

    blocTest<NotesBloc, NotesState>(
      'reports the error message when saving fails',
      setUp: () => when(
        () => repository.addNote(
          userId: any(named: 'userId'),
          lessonId: any(named: 'lessonId'),
          title: any(named: 'title'),
          content: any(named: 'content'),
        ),
      ).thenThrow(const NotesException('You seem to be offline.')),
      build: buildBloc,
      act: (bloc) => bloc.add(const NoteAdded(title: 'New', content: '')),
      expect: () => [
        const NotesState(
          message: 'You seem to be offline.',
          messageType: NotesMessageType.error,
        ),
      ],
    );
  });

  group('NoteUpdated', () {
    blocTest<NotesBloc, NotesState>(
      'sends the edited note to the repository',
      setUp: () =>
          when(() => repository.updateNote(any())).thenAnswer((_) async {}),
      build: buildBloc,
      act: (bloc) => bloc.add(
        NoteUpdated(note: note, title: 'Edited', content: 'New body'),
      ),
      expect: () => [const NotesState(message: 'Note updated')],
      verify: (_) => verify(
        () => repository.updateNote(
          note.copyWith(title: 'Edited', content: 'New body'),
        ),
      ).called(1),
    );

    blocTest<NotesBloc, NotesState>(
      'reports the error message when the update fails',
      setUp: () =>
          when(() => repository.updateNote(any()))
              .thenThrow(const NotesException('This note no longer exists.')),
      build: buildBloc,
      act: (bloc) => bloc.add(
        NoteUpdated(note: note, title: 'Edited', content: 'New body'),
      ),
      expect: () => [
        const NotesState(
          message: 'This note no longer exists.',
          messageType: NotesMessageType.error,
        ),
      ],
    );
  });

  group('NoteDeleted', () {
    blocTest<NotesBloc, NotesState>(
      'removes the note at once, then reports success',
      setUp: () =>
          when(() => repository.deleteNote(any())).thenAnswer((_) async {}),
      build: buildBloc,
      seed: () => NotesState(status: NotesStatus.success, notes: [note]),
      act: (bloc) => bloc.add(NoteDeleted(note)),
      expect: () => [
        const NotesState(status: NotesStatus.success),
        const NotesState(status: NotesStatus.success, message: 'Note deleted'),
      ],
      verify: (_) => verify(() => repository.deleteNote('note-1')).called(1),
    );

    blocTest<NotesBloc, NotesState>(
      'puts the note back when the delete fails',
      setUp: () =>
          when(() => repository.deleteNote(any()))
              .thenThrow(const NotesException("You don't have permission.")),
      build: buildBloc,
      seed: () => NotesState(status: NotesStatus.success, notes: [note]),
      act: (bloc) => bloc.add(NoteDeleted(note)),
      expect: () => [
        const NotesState(status: NotesStatus.success),
        NotesState(
          status: NotesStatus.success,
          notes: [note],
          message: "You don't have permission.",
          messageType: NotesMessageType.error,
        ),
      ],
    );
  });
}
