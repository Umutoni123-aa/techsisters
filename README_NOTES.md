# Saved notes feature — TechSisters (Nicole)

Learners can create, read, update and delete their own notes, optionally
linked to a lesson. Built with BLoC and Cloud Firestore, using the group's
Figma theme (`AppColors`, `AppSpacing`) and shared widgets (`AppCard`,
`AppTextField`, `PrimaryButton`).

## Files

These go into the empty `lib/features/notes/` folders from the architecture branch.

```
lib/features/notes/
  domain/
    entities/note.dart                    Note (matches the ERD)
    repositories/notes_repository.dart    Contract + NotesException
    usecases/note_usecases.dart           Watch / Add / Update / Delete
    validators/note_validator.dart        Title and content rules
  data/
    datasources/notes_remote_datasource.dart   Only class that uses Firestore
    models/note_model.dart                     Firestore <-> Note
    repositories/notes_repository_impl.dart    Turns errors into friendly messages
  presentation/
    bloc/notes_bloc.dart, notes_event.dart, notes_state.dart
    pages/notes_page.dart          "My notes" list (Read, Delete)
    pages/note_editor_page.dart    Create / Update form
    widgets/note_card.dart, note_body_field.dart,
            empty_notes_view.dart, delete_note_dialog.dart
test/features/notes/
  domain/note_validator_test.dart            unit
  data/note_model_test.dart                  unit
  data/notes_repository_impl_test.dart       unit (fake Firestore)
  presentation/notes_bloc_test.dart          unit (BLoC + use cases)
  presentation/notes_view_test.dart          widget
firestore.rules          Group rules with a stricter notes block
firestore.indexes.json   Index for the notes list query
```

## Before you start

The notes screens use `lib/core/theme/` and `lib/core/widgets/` from the
`feature/theme-navigation` branch. They must be merged into `main` first,
or the app will not compile.

## Setup

1. Make your branch from the latest `main`:

   ```bash
   git checkout main
   git pull
   git checkout -b feature/saved-notes
   ```

2. Copy the files into the same paths in the project. Delete the `.gitkeep`
   files in any notes folder that now has real files.

3. Add the packages (`flutter_bloc`, `equatable`, `bloc_test` and `mocktail`
   are already in `pubspec.yaml`):

   ```bash
   flutter pub add cloud_firestore bloc_concurrency
   flutter pub add --dev fake_cloud_firestore
   ```

4. Provide the repository once in `main.dart`. Add it to the existing
   `MultiBlocProvider`, or wrap it with a `RepositoryProvider`:

   ```dart
   RepositoryProvider<NotesRepository>(
     create: (_) => NotesRepositoryImpl(dataSource: NotesRemoteDataSource()),
     child: /* the existing MultiBlocProvider */,
   )
   ```

5. Open the screen with the learner's UID. For example, add a "My notes"
   card to the Profile screen:

   ```dart
   AppCard(
     onTap: () => Navigator.of(context).push(
       MaterialPageRoute(
         builder: (_) => NotesPage(
           userId: FirebaseAuth.instance.currentUser!.uid,
         ),
       ),
     ),
     child: const Text('My notes'),
   )
   ```

   From a lesson screen, pass the lesson so new notes are linked to it:
   `NotesPage(userId: uid, lessonId: lesson.id)`.

6. Replace the project's `firestore.rules` with this one (only the notes
   block changed), then deploy the rules and the index:

   ```bash
   firebase deploy --only firestore:rules,firestore:indexes
   ```

   If the index is missing, the debug console prints a link that creates it.

## Database

| notes | Type | Key |
|---|---|---|
| noteId | string (document ID) | PK |
| userId | string | FK → users.uid |
| lessonId | string or null | FK → lessons.lessonId (optional) |
| title | string, 1–100 characters | |
| content | string, up to 5000 characters | |
| createdAt | timestamp (server) | |
| updatedAt | timestamp (server) | |

A user writes many notes (1 : N). A note can be about one lesson (N : 0..1).

## Checks

```bash
dart format .
flutter analyze
flutter test --coverage
```

## Suggested commits

1. `feat(notes): add Note entity, repository contract and use cases`
2. `feat(notes): add note validator`
3. `feat(notes): add Firestore data source, model and repository`
4. `feat(notes): add NotesBloc with create, read, update and delete`
5. `feat(notes): add My notes and note editor screens`
6. `feat(notes): open My notes from the profile screen`
7. `test(notes): add unit tests for validator, model, repository and bloc`
8. `test(notes): add widget tests for the notes screen`
9. `feat(firebase): tighten notes security rules and add index`

## Demo video (your part)

1. Open My notes and create a note. Show the new document in the Firebase Console.
2. Edit it. Show `title` and `updatedAt` change in the console.
3. Swipe it left, confirm, and show the document disappear.
4. Try to save with an empty title to show the validation message.
