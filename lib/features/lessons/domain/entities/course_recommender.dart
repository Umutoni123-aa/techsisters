import 'package:techsisters/features/lessons/domain/entities/course.dart';
import 'package:techsisters/features/lessons/domain/entities/lesson_progress.dart';
import 'package:techsisters/features/onboarding/domain/entities/learner_profile.dart';

/// Chooses the course shown as "Start here" for a learner.
class CourseRecommender {
  CourseRecommender._();

  /// Returns the id of the recommended course, or null when every course is
  /// already finished.
  ///
  /// Rules, in order:
  /// 1. Skip courses the learner has completed.
  /// 2. Keep courses that match their goal (all of them for "both" or when no
  ///    goal was given). If none match, fall back to every unfinished course.
  /// 3. If one of those is already started, suggest it so they carry on.
  /// 4. Otherwise a confident learner gets the most advanced course (highest
  ///    `order`); everyone else gets the first one (lowest `order`).
  static String? pick({
    required List<Course> courses,
    required Map<String, LessonProgress> progress,
    required LearnerProfile profile,
  }) {
    final unfinished = courses
        .where((course) => !_isCompleted(course, progress))
        .toList();
    if (unfinished.isEmpty) return null;

    final matching = unfinished.where((c) => _matchesGoal(c, profile)).toList();
    final pool = matching.isNotEmpty ? matching : unfinished;
    pool.sort((a, b) => a.order.compareTo(b.order));

    // Carry on with a course that was already started.
    for (final course in pool) {
      if ((progress[course.id]?.completedLessons ?? 0) > 0) return course.id;
    }

    return profile.level == SkillLevel.confident ? pool.last.id : pool.first.id;
  }

  static bool _isCompleted(
    Course course,
    Map<String, LessonProgress> progress,
  ) {
    final done = progress[course.id]?.completedLessons ?? 0;
    return course.lessonCount > 0 && done >= course.lessonCount;
  }

  /// Compares the learner's goal with the course category by name:
  /// "coding" matches "Coding", "ai" matches "AI Literacy".
  static bool _matchesGoal(Course course, LearnerProfile profile) {
    final category = course.category.toLowerCase();
    switch (profile.goal) {
      case LearningGoal.coding:
        return category.contains('coding');
      case LearningGoal.ai:
        return category.contains('ai');
      case LearningGoal.both:
      case null:
        return true;
    }
  }
}
