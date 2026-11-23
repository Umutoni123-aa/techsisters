import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/note.dart';
import '../../domain/repositories/notes_repository.dart';
import '../../domain/usecases/note_usecases.dart';

part 'notes_event.dart';
part 'notes_state.dart';

/// Handles all note logic. Widgets only add events and read [NotesState];
/// they never call Firestore themselves.
class NotesBloc extends Bloc<NotesEvent, NotesState> {
  NotesBloc({
    required this._watchNotes,
    required this._addNote,
    required this._updateNote,
    required this._deleteNote,
    required this._userId,
  }) : super(const NotesState()) {
    // restartable() cancels the old Firestore listener if the list is
    // requested again (for example from the "Try again" button).
    on<NotesSubscriptionRequested>(
      _onSubscriptionRequested,
      transformer: restartable(),
    );
    on<NoteAdded>(_onNoteAdded);
    on<NoteUpdated>(_onNoteUpdated);
    on<NoteDeleted>(_onNoteDeleted);
  }

  /// Builds the BLoC and its use cases from a single repository.
  factory NotesBloc.fromRepository({
    required NotesRepository repository,
    required String userId,
  }) {
    return NotesBloc(
      watchNotes: WatchNotesUseCase(repository),
      addNote: AddNoteUseCase(repository),
      updateNote: UpdateNoteUseCase(repository),
      deleteNote: DeleteNoteUseCase(repository),
      userId: userId,
    );
  }

  final WatchNotesUseCase _watchNotes;
  final AddNoteUseCase _addNote;
  final UpdateNoteUseCase _updateNote;
  final DeleteNoteUseCase _deleteNote;
  final String _userId;

  Future<void> _onSubscriptionRequested(
    NotesSubscriptionRequested event,
    Emitter<NotesState> emit,
  ) async {
    emit(state.copyWith(status: NotesStatus.loading));

    // emit.forEach keeps listening until the BLoC is closed, so every change
    // in Firestore (including ones from this phone) reaches the UI at once.
    await emit.forEach<List<Note>>(
      _watchNotes(_userId),
      onData: (notes) => state.copyWith(
        status: NotesStatus.success,
        notes: notes,
        message: () => null,
      ),
      onError: (error, _) => state.copyWith(
        status: NotesStatus.failure,
        message: () => _messageFor(error),
        messageType: NotesMessageType.error,
      ),
    );
  }

  Future<void> _onNoteAdded(NoteAdded event, Emitter<NotesState> emit) {
    return _runAction(
      emit,
      () => _addNote(
        userId: _userId,
        lessonId: event.lessonId,
        title: event.title,
        content: event.content,
      ),
      successMessage: 'Note saved',
    );
  }

  Future<void> _onNoteUpdated(NoteUpdated event, Emitter<NotesState> emit) {
    return _runAction(
      emit,
      () => _updateNote(event.note, title: event.title, content: event.content),
      successMessage: 'Note updated',
    );
  }

  Future<void> _onNoteDeleted(
    NoteDeleted event,
    Emitter<NotesState> emit,
  ) async {
    // Remove the note from the list straight away. A swiped (Dismissible)
    // card must leave the widget tree at once, and it makes the app feel
    // instant. If the delete fails, the note is put back.
    final previousNotes = state.notes;
    emit(
      state.copyWith(
        notes: previousNotes.where((n) => n.id != event.note.id).toList(),
      ),
    );

    try {
      await _deleteNote(event.note);
      emit(
        state.copyWith(
          message: () => 'Note deleted',
          messageType: NotesMessageType.info,
        ),
      );
    } catch (error) {
      // Put back only this note, so other changes made meanwhile are kept.
      final restored = [
        ...state.notes.where((n) => n.id != event.note.id),
        event.note,
      ]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      emit(
        state.copyWith(
          notes: restored,
          message: () => _messageFor(error),
          messageType: NotesMessageType.error,
        ),
      );
    }
  }

  /// Runs a create or update and reports the result as a snackbar message.
  /// The list itself is refreshed by the Firestore stream, not here.
  Future<void> _runAction(
    Emitter<NotesState> emit,
    Future<void> Function() action, {
    required String successMessage,
  }) async {
    try {
      await action();
      emit(
        state.copyWith(
          message: () => successMessage,
          messageType: NotesMessageType.info,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          message: () => _messageFor(error),
          messageType: NotesMessageType.error,
        ),
      );
    }
  }

  String _messageFor(Object error) {
    if (error is NotesException) return error.message;
    return 'Something went wrong. Please try again.';
  }
}
