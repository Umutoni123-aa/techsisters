import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:techsisters/core/theme/app_theme.dart';
import 'package:techsisters/features/notes/domain/entities/note.dart';
import 'package:techsisters/features/notes/presentation/bloc/notes_bloc.dart';
import 'package:techsisters/features/notes/presentation/pages/notes_page.dart';

class MockNotesBloc extends MockBloc<NotesEvent, NotesState>
    implements NotesBloc {}

void main() {
  late MockNotesBloc bloc;

  final note = Note(
    id: 'note-1',
    userId: 'user-1',
    title: 'Group meeting',
    content: 'Agree on the ERD',
    createdAt: DateTime(2026, 11, 18),
    updatedAt: DateTime(2026, 11, 18),
  );

  setUpAll(() => registerFallbackValue(const NotesSubscriptionRequested()));

  setUp(() => bloc = MockNotesBloc());

  Future<void> pumpNotesView(WidgetTester tester, NotesState state) {
    when(() => bloc.state).thenReturn(state);
    return tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: BlocProvider<NotesBloc>.value(
          value: bloc,
          child: const NotesView(),
        ),
      ),
    );
  }

  testWidgets('shows a spinner while notes load', (tester) async {
    await pumpNotesView(tester, const NotesState(status: NotesStatus.loading));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows the empty message when there are no notes', (
    tester,
  ) async {
    await pumpNotesView(tester, const NotesState(status: NotesStatus.success));

    expect(find.text('No notes yet'), findsOneWidget);
  });

  testWidgets('lists each saved note', (tester) async {
    await pumpNotesView(
      tester,
      NotesState(status: NotesStatus.success, notes: [note]),
    );

    expect(find.text('Group meeting'), findsOneWidget);
    expect(find.text('Agree on the ERD'), findsOneWidget);
  });

  testWidgets('blocks saving a note with no title', (tester) async {
    await pumpNotesView(tester, const NotesState(status: NotesStatus.success));

    await tester.tap(find.byKey(const Key('notes_add_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('note_editor_save_button')));
    await tester.pump();

    expect(find.text('Please give your note a title.'), findsOneWidget);
    verifyNever(() => bloc.add(any()));
  });

  testWidgets('adds a NoteAdded event when a valid note is saved', (
    tester,
  ) async {
    await pumpNotesView(tester, const NotesState(status: NotesStatus.success));

    await tester.tap(find.byKey(const Key('notes_add_button')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('note_editor_title_field')),
      'Shopping list',
    );
    await tester.enterText(
      find.byKey(const Key('note_editor_content_field')),
      'Bread',
    );
    await tester.tap(find.byKey(const Key('note_editor_save_button')));
    await tester.pumpAndSettle();

    verify(
      () => bloc.add(const NoteAdded(title: 'Shopping list', content: 'Bread')),
    ).called(1);
    // The editor closes and the list screen is shown again.
    expect(find.text('My notes'), findsOneWidget);
  });

  testWidgets('shows a polite SnackBar when an action fails', (tester) async {
    const loaded = NotesState(status: NotesStatus.success);
    // whenListen stubs the bloc's stream, so the page's listener runs.
    whenListen(
      bloc,
      Stream.fromIterable([
        loaded.copyWith(
          message: () => "You don't have permission to change this note.",
          messageType: NotesMessageType.error,
        ),
      ]),
      initialState: loaded,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: BlocProvider<NotesBloc>.value(
          value: bloc,
          child: const NotesView(),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(
      find.text("You don't have permission to change this note."),
      findsOneWidget,
    );
  });
}
