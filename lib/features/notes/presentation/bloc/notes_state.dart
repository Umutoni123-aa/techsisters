part of 'notes_bloc.dart';

enum NotesStatus { initial, loading, success, failure }

/// Whether a one-off [NotesState.message] reports success or an error.
/// The page uses this to colour its snackbar.
enum NotesMessageType { info, error }

final class NotesState extends Equatable {
  const NotesState({
    this.status = NotesStatus.initial,
    this.notes = const [],
    this.message,
    this.messageType = NotesMessageType.info,
  });

  final NotesStatus status;
  final List<Note> notes;

  /// A short message for a snackbar, such as "Note saved". It is cleared
  /// on the next list update so the same message can be shown again later.
  final String? message;
  final NotesMessageType messageType;

  NotesState copyWith({
    NotesStatus? status,
    List<Note>? notes,
    String? Function()? message,
    NotesMessageType? messageType,
  }) {
    return NotesState(
      status: status ?? this.status,
      notes: notes ?? this.notes,
      // A function is used so callers can set the message back to null.
      message: message != null ? message() : this.message,
      messageType: messageType ?? this.messageType,
    );
  }

  @override
  List<Object?> get props => [status, notes, message, messageType];
}
