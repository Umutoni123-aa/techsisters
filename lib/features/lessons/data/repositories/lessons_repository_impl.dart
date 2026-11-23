import 'package:techsisters/features/lessons/data/datasources/lessons_firestore_datasource.dart';
import 'package:techsisters/features/lessons/domain/entities/course.dart';
import 'package:techsisters/features/lessons/domain/entities/lesson.dart';
import 'package:techsisters/features/lessons/domain/entities/lesson_progress.dart';
import 'package:techsisters/features/lessons/domain/entities/user_stats.dart';
import 'package:techsisters/features/lessons/domain/repositories/lessons_repository.dart';

class LessonsRepositoryImpl implements LessonsRepository {
  final LessonsFirestoreDatasource datasource;

  LessonsRepositoryImpl(this.datasource);

  @override
  Stream<List<Course>> watchCourses() => datasource.watchCourses();

  @override
  Stream<Map<String, LessonProgress>> watchProgress(String userId) =>
      datasource.watchProgress(userId);

  @override
  Stream<UserStats> watchStats(String userId) => datasource.watchStats(userId);

  @override
  Future<List<Lesson>> getLessons(String courseId) =>
      datasource.getLessons(courseId);

  @override
  Future<void> saveCompletion({
    required String userId,
    required String courseId,
    required int completedLessons,
    required UserStats stats,
  }) => datasource.saveCompletion(userId, courseId, completedLessons, stats);

  @override
  Future<void> resetProgress({
    required String userId,
    required String courseId,
  }) => datasource.resetProgress(userId, courseId);
}
