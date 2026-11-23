import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:techsisters/features/lessons/domain/entities/lesson_scoring.dart';
import 'package:techsisters/features/lessons/domain/entities/user_stats.dart';
import 'package:techsisters/features/lessons/domain/repositories/lessons_repository.dart';
import 'package:techsisters/features/lessons/domain/usecases/lessons_usecases.dart';

class MockLessonsRepository extends Mock implements LessonsRepository {}

void main() {
  group('LessonScoring', () {
    test('a perfect lesson gives 5 points per question', () {
      expect(
        LessonScoring.pointsFor(totalQuestions: 4, firstTryCorrect: 4),
        20,
      );
    });

    test('questions that needed a retry give fewer points', () {
      expect(
        LessonScoring.pointsFor(totalQuestions: 4, firstTryCorrect: 1),
        11,
      );
      expect(LessonScoring.pointsFor(totalQuestions: 2, firstTryCorrect: 0), 4);
    });

    test('first-try count is kept inside the valid range', () {
      expect(
        LessonScoring.pointsFor(totalQuestions: 2, firstTryCorrect: 9),
        10,
      );
    });
  });

  group('UserStats', () {
    final day1 = DateTime(2026, 11, 20, 9);

    test('first lesson adds the points and starts a 1-day streak', () {
      final stats = UserStats.empty.afterLesson(day1, points: 20);
      expect(stats.xp, 20);
      expect(stats.streak, 1);
    });

    test('same day keeps the streak, next day extends it, a gap resets it', () {
      final first = UserStats.empty.afterLesson(day1, points: 20);
      final sameDay = first.afterLesson(DateTime(2026, 11, 20, 18), points: 20);
      final nextDay = sameDay.afterLesson(
        DateTime(2026, 11, 21, 8),
        points: 20,
      );
      final afterGap = nextDay.afterLesson(
        DateTime(2026, 11, 25, 8),
        points: 20,
      );

      expect(sameDay.streak, 1);
      expect(nextDay.streak, 2);
      expect(afterGap.streak, 1);
      expect(afterGap.xp, 80);
    });

    test('level and XP in level come from total XP', () {
      const stats = UserStats(xp: 1440, streak: 1);
      expect(stats.level, 3);
      expect(stats.xpInLevel, 240);
    });
  });

  group('CompleteLessonUseCase', () {
    setUpAll(() => registerFallbackValue(UserStats.empty));

    late MockLessonsRepository repository;
    late CompleteLessonUseCase completeLesson;
    final now = DateTime(2026, 11, 20, 9);

    setUp(() {
      repository = MockLessonsRepository();
      completeLesson = CompleteLessonUseCase(repository);
      when(
        () => repository.saveCompletion(
          userId: any(named: 'userId'),
          courseId: any(named: 'courseId'),
          completedLessons: any(named: 'completedLessons'),
          stats: any(named: 'stats'),
        ),
      ).thenAnswer((_) async {});
    });

    test(
      'a new lesson awards score-based points and saves the count',
      () async {
        final result = await completeLesson(
          userId: 'u1',
          courseId: 'c1',
          lessonIndex: 1,
          currentCompleted: 1,
          currentStats: const UserStats(xp: 100, streak: 0),
          totalQuestions: 3,
          firstTryCorrect: 2,
          now: now,
        );

        // 2 first-try (10) + 1 retry (2) = 12 points.
        expect(result.pointsEarned, 12);
        expect(result.completedLessons, 2);
        expect(result.stats.xp, 112);
        verify(
          () => repository.saveCompletion(
            userId: 'u1',
            courseId: 'c1',
            completedLessons: 2,
            stats: result.stats,
          ),
        ).called(1);
      },
    );

    test('replaying a finished lesson gives no points', () async {
      const stats = UserStats(xp: 100, streak: 3);
      final result = await completeLesson(
        userId: 'u1',
        courseId: 'c1',
        lessonIndex: 0,
        currentCompleted: 3,
        currentStats: stats,
        totalQuestions: 3,
        firstTryCorrect: 3,
        now: now,
      );

      expect(result.completedLessons, 3);
      expect(result.pointsEarned, 0);
      expect(result.stats, stats);
    });
  });
}
