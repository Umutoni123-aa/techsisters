import 'package:techsisters/features/lessons/data/datasources/lessons_firestore_datasource.dart';
import 'package:techsisters/features/lessons/data/repositories/lessons_repository_impl.dart';
import 'package:techsisters/features/lessons/domain/usecases/lessons_usecases.dart';

/// Builds the lessons feature's use cases once, so pages can share them.
class LessonsModule {
  final WatchCoursesUseCase watchCourses;
  final WatchProgressUseCase watchProgress;
  final WatchStatsUseCase watchStats;
  final GetLessonsUseCase getLessons;
  final CompleteLessonUseCase completeLesson;
  final ResetProgressUseCase resetProgress;

  LessonsModule._({
    required this.watchCourses,
    required this.watchProgress,
    required this.watchStats,
    required this.getLessons,
    required this.completeLesson,
    required this.resetProgress,
  });

  factory LessonsModule() {
    final repository = LessonsRepositoryImpl(LessonsFirestoreDatasource());
    return LessonsModule._(
      watchCourses: WatchCoursesUseCase(repository),
      watchProgress: WatchProgressUseCase(repository),
      watchStats: WatchStatsUseCase(repository),
      getLessons: GetLessonsUseCase(repository),
      completeLesson: CompleteLessonUseCase(repository),
      resetProgress: ResetProgressUseCase(repository),
    );
  }
}
