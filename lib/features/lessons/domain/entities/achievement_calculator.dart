import 'package:techsisters/features/lessons/domain/entities/achievement.dart';
import 'package:techsisters/features/lessons/domain/entities/course.dart';
import 'package:techsisters/features/lessons/domain/entities/lesson_progress.dart';
import 'package:techsisters/features/lessons/domain/entities/user_stats.dart';

/// Works out badges, milestones and certificates from data we already store
/// (progress per course, XP and streak). Nothing extra is saved in Firestore.
class AchievementCalculator {
  AchievementCalculator._();

  static AchievementSummary build({
    required List<Course> courses,
    required Map<String, LessonProgress> progress,
    required UserStats stats,
  }) {
    final lessonsDone = _lessonsDone(courses, progress);
    final certificates = _certificates(courses, progress);

    final achievements = [
      Achievement(
        id: 'first_lesson',
        title: 'First step',
        description: 'Finish your first lesson',
        earned: lessonsDone >= 1,
      ),
      Achievement(
        id: 'three_lessons',
        title: 'Getting going',
        description: 'Finish 3 lessons',
        earned: lessonsDone >= 3,
      ),
      Achievement(
        id: 'five_lessons',
        title: 'On a roll',
        description: 'Finish 5 lessons',
        earned: lessonsDone >= 5,
      ),
      Achievement(
        id: 'streak_3',
        title: '3-day streak',
        description: 'Learn 3 days in a row',
        earned: stats.streak >= 3,
      ),
      Achievement(
        id: 'points_50',
        title: 'Rising star',
        description: 'Earn 50 points',
        earned: stats.xp >= 50,
      ),
      Achievement(
        id: 'first_course',
        title: 'Course complete',
        description: 'Finish a whole course',
        earned: certificates.isNotEmpty,
      ),
    ];

    return AchievementSummary(
      lessonsDone: lessonsDone,
      streak: stats.streak,
      points: stats.xp,
      achievements: achievements,
      certificates: certificates,
    );
  }

  /// Lessons finished across all courses. A course's count is capped at its
  /// number of lessons, in case a lesson was removed after being finished.
  static int _lessonsDone(
    List<Course> courses,
    Map<String, LessonProgress> progress,
  ) {
    var total = 0;
    for (final course in courses) {
      final done = progress[course.id]?.completedLessons ?? 0;
      total += done > course.lessonCount ? course.lessonCount : done;
    }
    return total;
  }

  /// One certificate for every course whose lessons are all finished.
  static List<Certificate> _certificates(
    List<Course> courses,
    Map<String, LessonProgress> progress,
  ) {
    final certificates = <Certificate>[];
    for (final course in courses) {
      final entry = progress[course.id];
      if (entry == null || course.lessonCount == 0) continue;
      if (entry.completedLessons >= course.lessonCount) {
        certificates.add(
          Certificate(
            courseId: course.id,
            courseTitle: course.title,
            completedOn: entry.updatedAt,
          ),
        );
      }
    }
    return certificates;
  }
}
