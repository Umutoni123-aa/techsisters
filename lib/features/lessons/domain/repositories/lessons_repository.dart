import 'package:techsisters/features/lessons/domain/entities/course.dart';
import 'package:techsisters/features/lessons/domain/entities/lesson.dart';
import 'package:techsisters/features/lessons/domain/entities/lesson_progress.dart';
import 'package:techsisters/features/lessons/domain/entities/user_stats.dart';

/// Contract for reading courses and managing a user's progress.
abstract class LessonsRepository {
  /// Read: live list of courses ordered by `order`.
  Stream<List<Course>> watchCourses();

  /// Read: live progress of [userId], keyed by course id.
  Stream<Map<String, LessonProgress>> watchProgress(String userId);

  /// Read: live XP and streak of [userId].
  Stream<UserStats> watchStats(String userId);

  /// Read: the lessons of a course, ordered.
  Future<List<Lesson>> getLessons(String courseId);

  /// Create/Update: store finished lessons and the new stats together.
  Future<void> saveCompletion({
    required String userId,
    required String courseId,
    required int completedLessons,
    required UserStats stats,
  });

  /// Delete: reset progress on a course.
  Future<void> resetProgress({
    required String userId,
    required String courseId,
  });
}
