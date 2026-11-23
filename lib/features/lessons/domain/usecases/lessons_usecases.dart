import 'package:equatable/equatable.dart';
import 'package:techsisters/features/lessons/domain/entities/course.dart';
import 'package:techsisters/features/lessons/domain/entities/lesson.dart';
import 'package:techsisters/features/lessons/domain/entities/lesson_progress.dart';
import 'package:techsisters/features/lessons/domain/entities/lesson_scoring.dart';
import 'package:techsisters/features/lessons/domain/entities/user_stats.dart';
import 'package:techsisters/features/lessons/domain/repositories/lessons_repository.dart';

class WatchCoursesUseCase {
  final LessonsRepository repository;
  WatchCoursesUseCase(this.repository);

  Stream<List<Course>> call() => repository.watchCourses();
}

class WatchProgressUseCase {
  final LessonsRepository repository;
  WatchProgressUseCase(this.repository);

  Stream<Map<String, LessonProgress>> call(String userId) =>
      repository.watchProgress(userId);
}

class WatchStatsUseCase {
  final LessonsRepository repository;
  WatchStatsUseCase(this.repository);

  Stream<UserStats> call(String userId) => repository.watchStats(userId);
}

class GetLessonsUseCase {
  final LessonsRepository repository;
  GetLessonsUseCase(this.repository);

  Future<List<Lesson>> call(String courseId) => repository.getLessons(courseId);
}

/// What a finished lesson changed, so the success sheet can show it.
class CompletionResult extends Equatable {
  final int completedLessons;
  final UserStats stats;
  final int pointsEarned;

  const CompletionResult({
    required this.completedLessons,
    required this.stats,
    required this.pointsEarned,
  });

  @override
  List<Object?> get props => [completedLessons, stats, pointsEarned];
}

/// Records a finished lesson (every question answered correctly). Points and
/// streak are only awarded the first time a lesson is finished, so replaying
/// it cannot farm XP.
class CompleteLessonUseCase {
  final LessonsRepository repository;
  CompleteLessonUseCase(this.repository);

  Future<CompletionResult> call({
    required String userId,
    required String courseId,
    required int lessonIndex,
    required int currentCompleted,
    required UserStats currentStats,
    required int totalQuestions,
    required int firstTryCorrect,
    DateTime? now,
  }) async {
    final alreadyDone = lessonIndex < currentCompleted;
    final completed = alreadyDone ? currentCompleted : lessonIndex + 1;
    final points = alreadyDone
        ? 0
        : LessonScoring.pointsFor(
            totalQuestions: totalQuestions,
            firstTryCorrect: firstTryCorrect,
          );
    final stats = alreadyDone
        ? currentStats
        : currentStats.afterLesson(now ?? DateTime.now(), points: points);

    await repository.saveCompletion(
      userId: userId,
      courseId: courseId,
      completedLessons: completed,
      stats: stats,
    );
    return CompletionResult(
      completedLessons: completed,
      stats: stats,
      pointsEarned: points,
    );
  }
}

class ResetProgressUseCase {
  final LessonsRepository repository;
  ResetProgressUseCase(this.repository);

  Future<void> call({required String userId, required String courseId}) {
    return repository.resetProgress(userId: userId, courseId: courseId);
  }
}
