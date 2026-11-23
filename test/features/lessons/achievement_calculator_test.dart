import 'package:flutter_test/flutter_test.dart';
import 'package:techsisters/features/lessons/domain/entities/achievement_calculator.dart';
import 'package:techsisters/features/lessons/domain/entities/course.dart';
import 'package:techsisters/features/lessons/domain/entities/lesson_progress.dart';
import 'package:techsisters/features/lessons/domain/entities/user_stats.dart';

Course _course(String id, int lessons) => Course(
  id: id,
  title: 'Course $id',
  description: '',
  category: 'Coding',
  lessonCount: lessons,
  minutesPerLesson: 5,
  sizeMb: 1,
  order: 1,
);

LessonProgress _progress(String id, int done) => LessonProgress(
  courseId: id,
  completedLessons: done,
  updatedAt: DateTime(2026, 11, 22),
);

void main() {
  final courses = [_course('a', 3), _course('b', 2)];

  /// Ids of the badges that are earned in [summary].
  Set<String> earned(summary) => {
    for (final a in summary.achievements)
      if (a.earned) a.id,
  };

  test('a new learner has no badges and no certificates', () {
    final summary = AchievementCalculator.build(
      courses: courses,
      progress: {},
      stats: UserStats.empty,
    );

    expect(summary.lessonsDone, 0);
    expect(summary.badgesEarned, 0);
    expect(summary.certificates, isEmpty);
  });

  test('lessons across courses add up and unlock the lesson badges', () {
    final summary = AchievementCalculator.build(
      courses: courses,
      progress: {'a': _progress('a', 2), 'b': _progress('b', 1)},
      stats: UserStats.empty,
    );

    expect(summary.lessonsDone, 3);
    expect(earned(summary), {'first_lesson', 'three_lessons'});
  });

  test('streak and points unlock their own badges', () {
    final summary = AchievementCalculator.build(
      courses: courses,
      progress: {},
      stats: const UserStats(xp: 50, streak: 3),
    );

    expect(earned(summary), {'streak_3', 'points_50'});
  });

  test('a finished course gives a certificate and the course badge', () {
    final summary = AchievementCalculator.build(
      courses: courses,
      progress: {'b': _progress('b', 2)},
      stats: UserStats.empty,
    );

    expect(summary.certificates.single.courseTitle, 'Course b');
    expect(summary.certificates.single.completedOn, DateTime(2026, 11, 22));
    expect(earned(summary).contains('first_course'), isTrue);
  });

  test('progress above the lesson count is capped', () {
    final summary = AchievementCalculator.build(
      courses: courses,
      progress: {'a': _progress('a', 9)},
      stats: UserStats.empty,
    );

    expect(summary.lessonsDone, 3);
  });
}
