import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:techsisters/features/lessons/domain/entities/course.dart';
import 'package:techsisters/features/lessons/domain/entities/lesson.dart';
import 'package:techsisters/features/lessons/domain/entities/user_stats.dart';
import 'package:techsisters/features/lessons/domain/usecases/lessons_usecases.dart';

part 'lesson_session_event.dart';
part 'lesson_session_state.dart';

/// Runs one learning session on a course. A lesson has several questions:
/// the user answers them one by one (retrying wrong answers), and only after
/// the last one is correct is the lesson saved and the next one offered.
class LessonSessionBloc extends Bloc<LessonSessionEvent, LessonSessionState> {
  final Course course;
  final String userId;
  final GetLessonsUseCase getLessons;
  final CompleteLessonUseCase completeLesson;

  LessonSessionBloc({
    required this.course,
    required this.userId,
    required this.getLessons,
    required this.completeLesson,
    required int completedLessons,
    required UserStats stats,
  }) : super(
         LessonSessionState(completedLessons: completedLessons, stats: stats),
       ) {
    on<SessionStartedEvent>(_onStarted);
    on<OptionSelectedEvent>(_onOptionSelected);
    on<CheckAnswerEvent>(_onCheck);
    on<TryAgainEvent>(
      (e, emit) =>
          emit(state.copyWith(clearSelected: true, checkedWrong: false)),
    );
    on<NextQuestionEvent>(_onNextQuestion);
    on<NextLessonEvent>(_onNextLesson);
  }

  Future<void> _onStarted(
    SessionStartedEvent event,
    Emitter<LessonSessionState> emit,
  ) async {
    try {
      final lessons = (await getLessons(course.id))
          .where((l) => l.questions.isNotEmpty)
          .toList();
      if (lessons.isEmpty) {
        emit(
          state.copyWith(
            status: SessionStatus.error,
            errorMessage: 'This course has no lessons yet.',
          ),
        );
        return;
      }
      // Resume at the first unfinished lesson; replay from the start if the
      // whole course is already done.
      final done = state.completedLessons;
      final start = done >= lessons.length ? 0 : done;
      emit(
        state.copyWith(
          status: SessionStatus.ready,
          lessons: lessons,
          lessonIndex: start,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: SessionStatus.error,
          errorMessage: 'Could not load lessons: $e',
        ),
      );
    }
  }

  void _onOptionSelected(
    OptionSelectedEvent event,
    Emitter<LessonSessionState> emit,
  ) {
    // Once a question is answered correctly its choice is locked.
    if (state.saving || state.justCompleted || state.answeredCorrect) return;
    emit(state.copyWith(selected: event.index, checkedWrong: false));
  }

  Future<void> _onCheck(
    CheckAnswerEvent event,
    Emitter<LessonSessionState> emit,
  ) async {
    final question = state.question;
    final lesson = state.lesson;
    if (question == null || lesson == null) return;
    if (state.saving || state.answeredCorrect || state.justCompleted) return;

    // Validation: an answer must be picked first.
    final selected = state.selected;
    if (selected == null) {
      emit(
        state.copyWith(
          notice: 'Please choose an answer first.',
          noticeId: state.noticeId + 1,
        ),
      );
      return;
    }

    if (selected != question.correctIndex) {
      emit(
        state.copyWith(
          checkedWrong: true,
          wrongAttempts: state.wrongAttempts + 1,
        ),
      );
      return;
    }

    // Correct. Only a first-try answer counts towards the bonus points.
    final firstTry = state.firstTryCorrect + (state.wrongAttempts == 0 ? 1 : 0);

    if (!state.isLastQuestion) {
      emit(state.copyWith(answeredCorrect: true, firstTryCorrect: firstTry));
      return;
    }

    // Last question answered correctly: the lesson is complete, so save it.
    emit(state.copyWith(saving: true, firstTryCorrect: firstTry));
    try {
      final result = await completeLesson(
        userId: userId,
        courseId: course.id,
        lessonIndex: state.lessonIndex,
        currentCompleted: state.completedLessons,
        currentStats: state.stats,
        totalQuestions: lesson.questions.length,
        firstTryCorrect: firstTry,
      );
      emit(
        state.copyWith(
          saving: false,
          justCompleted: true,
          completedLessons: result.completedLessons,
          stats: result.stats,
          pointsEarned: result.pointsEarned,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          saving: false,
          notice: 'Could not save your progress: $e',
          noticeId: state.noticeId + 1,
        ),
      );
    }
  }

  void _onNextQuestion(
    NextQuestionEvent event,
    Emitter<LessonSessionState> emit,
  ) {
    if (!state.answeredCorrect || state.isLastQuestion) return;
    emit(
      state.copyWith(
        questionIndex: state.questionIndex + 1,
        clearSelected: true,
        checkedWrong: false,
        answeredCorrect: false,
        wrongAttempts: 0,
      ),
    );
  }

  void _onNextLesson(NextLessonEvent event, Emitter<LessonSessionState> emit) {
    if (state.isLastLesson) return;
    emit(
      state.copyWith(
        lessonIndex: state.lessonIndex + 1,
        questionIndex: 0,
        clearSelected: true,
        checkedWrong: false,
        answeredCorrect: false,
        wrongAttempts: 0,
        firstTryCorrect: 0,
        justCompleted: false,
        pointsEarned: 0,
      ),
    );
  }
}
