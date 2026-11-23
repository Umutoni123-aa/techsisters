import 'package:equatable/equatable.dart';

/// How many lessons of one course a user has finished, stored at
/// `users/{uid}/progress/{courseId}`.
class LessonProgress extends Equatable {
  final String courseId;
  final int completedLessons;
  final DateTime updatedAt;

  const LessonProgress({
    required this.courseId,
    required this.completedLessons,
    required this.updatedAt,
  });

  /// Completion from 0 to 100 for a course with [lessonCount] lessons.
  int percentOf(int lessonCount) {
    if (lessonCount <= 0) return 0;
    return (completedLessons * 100 ~/ lessonCount).clamp(0, 100);
  }

  @override
  List<Object?> get props => [courseId, completedLessons, updatedAt];
}
