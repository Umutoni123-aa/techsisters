part of 'lesson_session_bloc.dart';

abstract class LessonSessionEvent extends Equatable {
  const LessonSessionEvent();

  @override
  List<Object?> get props => [];
}

/// Load the course's lessons and jump to the first unfinished one.
class SessionStartedEvent extends LessonSessionEvent {
  const SessionStartedEvent();
}

class OptionSelectedEvent extends LessonSessionEvent {
  final int index;
  const OptionSelectedEvent(this.index);

  @override
  List<Object?> get props => [index];
}

class CheckAnswerEvent extends LessonSessionEvent {
  const CheckAnswerEvent();
}

/// After a wrong answer: clear the choice so the user can try again.
class TryAgainEvent extends LessonSessionEvent {
  const TryAgainEvent();
}

/// After a correct answer: move on to the next question of the lesson.
class NextQuestionEvent extends LessonSessionEvent {
  const NextQuestionEvent();
}

/// After the lesson is complete: move on to the next lesson of the course.
class NextLessonEvent extends LessonSessionEvent {
  const NextLessonEvent();
}
