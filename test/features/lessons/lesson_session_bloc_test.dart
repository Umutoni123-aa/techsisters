import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:techsisters/features/lessons/domain/entities/course.dart';
import 'package:techsisters/features/lessons/domain/entities/lesson.dart';
import 'package:techsisters/features/lessons/domain/entities/user_stats.dart';
import 'package:techsisters/features/lessons/domain/repositories/lessons_repository.dart';
import 'package:techsisters/features/lessons/domain/usecases/lessons_usecases.dart';
import 'package:techsisters/features/lessons/presentation/bloc/lesson_session_bloc.dart';

class MockLessonsRepository extends Mock implements LessonsRepository {}

Question _question(int correct) => Question(
  scenario: 'Scenario',
  prompt: null,
  question: 'Question?',
  options: const ['A', 'B', 'C', 'D'],
  correctIndex: correct,
  explanation: 'Because.',
  tags: const [],
);

void main() {
  const course = Course(
    id: 'c1',
    title: 'Course',
    description: '',
    category: 'Coding',
    lessonCount: 2,
    minutesPerLesson: 5,
    sizeMb: 1,
    order: 1,
  );

  // Lesson 1 has two questions (answers 0 and 1); lesson 2 has one.
  final lessons = [
    Lesson(
      id: 'l1',
      title: 'One',
      order: 1,
      questions: [_question(0), _question(1)],
    ),
    Lesson(id: 'l2', title: 'Two', order: 2, questions: [_question(2)]),
  ];

  late MockLessonsRepository repository;
  late LessonSessionBloc bloc;

  setUpAll(() => registerFallbackValue(UserStats.empty));

  setUp(() {
    repository = MockLessonsRepository();
    when(() => repository.getLessons('c1')).thenAnswer((_) async => lessons);
    when(
      () => repository.saveCompletion(
        userId: any(named: 'userId'),
        courseId: any(named: 'courseId'),
        completedLessons: any(named: 'completedLessons'),
        stats: any(named: 'stats'),
      ),
    ).thenAnswer((_) async {});
    bloc = LessonSessionBloc(
      course: course,
      userId: 'u1',
      getLessons: GetLessonsUseCase(repository),
      completeLesson: CompleteLessonUseCase(repository),
      completedLessons: 0,
      stats: UserStats.empty,
    );
  });

  tearDown(() => bloc.close());

  Future<void> send(LessonSessionEvent event) async {
    bloc.add(event);
    await pumpEventQueue();
  }

  test('starts on the first unfinished lesson and first question', () async {
    await send(const SessionStartedEvent());
    expect(bloc.state.status, SessionStatus.ready);
    expect(bloc.state.lessonIndex, 0);
    expect(bloc.state.questionIndex, 0);
  });

  test('checking with nothing selected shows a validation notice', () async {
    await send(const SessionStartedEvent());
    await send(const CheckAnswerEvent());
    expect(bloc.state.notice, 'Please choose an answer first.');
    expect(bloc.state.justCompleted, isFalse);
  });

  test('a wrong answer does not move on and needs a retry', () async {
    await send(const SessionStartedEvent());
    await send(const OptionSelectedEvent(3));
    await send(const CheckAnswerEvent());

    expect(bloc.state.checkedWrong, isTrue);
    expect(bloc.state.answeredCorrect, isFalse);
    expect(bloc.state.wrongAttempts, 1);

    await send(const TryAgainEvent());
    expect(bloc.state.selected, isNull);
    expect(bloc.state.checkedWrong, isFalse);
  });

  test('the lesson only completes after the LAST question is right', () async {
    await send(const SessionStartedEvent());

    // Question 1: correct first try -> explanation, not complete yet.
    await send(const OptionSelectedEvent(0));
    await send(const CheckAnswerEvent());
    expect(bloc.state.answeredCorrect, isTrue);
    expect(bloc.state.justCompleted, isFalse);
    verifyNever(
      () => repository.saveCompletion(
        userId: any(named: 'userId'),
        courseId: any(named: 'courseId'),
        completedLessons: any(named: 'completedLessons'),
        stats: any(named: 'stats'),
      ),
    );

    await send(const NextQuestionEvent());
    expect(bloc.state.questionIndex, 1);

    // Question 2: wrong first, then right -> complete with 5 + 2 points.
    await send(const OptionSelectedEvent(0));
    await send(const CheckAnswerEvent());
    await send(const TryAgainEvent());
    await send(const OptionSelectedEvent(1));
    await send(const CheckAnswerEvent());

    expect(bloc.state.justCompleted, isTrue);
    expect(bloc.state.pointsEarned, 7);
    expect(bloc.state.completedLessons, 1);
    expect(bloc.state.stats.xp, 7);
    verify(
      () => repository.saveCompletion(
        userId: 'u1',
        courseId: 'c1',
        completedLessons: 1,
        stats: any(named: 'stats'),
      ),
    ).called(1);
  });

  test('next lesson resets the question counters', () async {
    await send(const SessionStartedEvent());
    await send(const OptionSelectedEvent(0));
    await send(const CheckAnswerEvent());
    await send(const NextQuestionEvent());
    await send(const OptionSelectedEvent(1));
    await send(const CheckAnswerEvent());
    await send(const NextLessonEvent());

    expect(bloc.state.lessonIndex, 1);
    expect(bloc.state.questionIndex, 0);
    expect(bloc.state.justCompleted, isFalse);
    expect(bloc.state.firstTryCorrect, 0);
  });
}
