import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:techsisters/features/lessons/domain/entities/course.dart';
import 'package:techsisters/features/lessons/domain/entities/lesson_progress.dart';
import 'package:techsisters/features/lessons/domain/entities/user_stats.dart';
import 'package:techsisters/features/lessons/domain/usecases/lessons_usecases.dart';

part 'lessons_event.dart';
part 'lessons_state.dart';

/// Drives the course catalog. Combines the courses, progress and stats
/// streams into one state so the list and its filters stay in sync.
class LessonsBloc extends Bloc<LessonsEvent, LessonsState> {
  final WatchCoursesUseCase watchCourses;
  final WatchProgressUseCase watchProgress;
  final WatchStatsUseCase watchStats;
  final ResetProgressUseCase resetProgress;

  StreamSubscription<List<Course>>? _coursesSub;
  StreamSubscription<Map<String, LessonProgress>>? _progressSub;
  StreamSubscription<UserStats>? _statsSub;
  List<Course>? _courses;
  Map<String, LessonProgress>? _progress;
  UserStats? _stats;
  String? _userId;

  LessonsBloc({
    required this.watchCourses,
    required this.watchProgress,
    required this.watchStats,
    required this.resetProgress,
  }) : super(const LessonsInitial()) {
    on<LoadLessonsEvent>(_onLoad);
    on<LessonsDataChangedEvent>(_onDataChanged);
    on<LessonsFailedEvent>((e, emit) => emit(LessonsError(e.message)));
    on<SearchChangedEvent>(_onSearch);
    on<CategorySelectedEvent>(_onCategory);
    on<ResetProgressEvent>(_onReset);
  }

  Future<void> _onLoad(
    LoadLessonsEvent event,
    Emitter<LessonsState> emit,
  ) async {
    emit(const LessonsLoading());
    _userId = event.userId;
    _courses = null;
    _progress = null;
    _stats = null;
    await _coursesSub?.cancel();
    await _progressSub?.cancel();
    await _statsSub?.cancel();

    void fail(String what, Object e) =>
        add(LessonsFailedEvent('Could not load $what: $e'));

    _coursesSub = watchCourses().listen((v) {
      _courses = v;
      _publish();
    }, onError: (Object e) => fail('courses', e));
    _progressSub = watchProgress(event.userId).listen((v) {
      _progress = v;
      _publish();
    }, onError: (Object e) => fail('progress', e));
    _statsSub = watchStats(event.userId).listen((v) {
      _stats = v;
      _publish();
    }, onError: (Object e) => fail('your stats', e));
  }

  /// Emit only once all three streams have produced their first value.
  void _publish() {
    final courses = _courses;
    final progress = _progress;
    final stats = _stats;
    if (courses != null && progress != null && stats != null) {
      add(LessonsDataChangedEvent(courses, progress, stats));
    }
  }

  void _onDataChanged(
    LessonsDataChangedEvent event,
    Emitter<LessonsState> emit,
  ) {
    final current = state;
    if (current is LessonsLoaded) {
      // Keep the user's search text and selected chip across live updates.
      emit(
        current.copyWith(
          courses: event.courses,
          progress: event.progress,
          stats: event.stats,
        ),
      );
    } else {
      emit(
        LessonsLoaded(
          courses: event.courses,
          progress: event.progress,
          stats: event.stats,
        ),
      );
    }
  }

  void _onSearch(SearchChangedEvent event, Emitter<LessonsState> emit) {
    final current = state;
    if (current is LessonsLoaded) emit(current.copyWith(query: event.query));
  }

  void _onCategory(CategorySelectedEvent event, Emitter<LessonsState> emit) {
    final current = state;
    if (current is LessonsLoaded) {
      emit(current.copyWith(category: event.category));
    }
  }

  Future<void> _onReset(
    ResetProgressEvent event,
    Emitter<LessonsState> emit,
  ) async {
    final userId = _userId;
    if (userId == null) return;
    try {
      await resetProgress(userId: userId, courseId: event.courseId);
    } catch (e) {
      final current = state;
      if (current is LessonsLoaded) {
        emit(
          current.copyWith(
            message: 'Could not reset progress: $e',
            messageId: current.messageId + 1,
          ),
        );
      }
    }
  }

  @override
  Future<void> close() async {
    await _coursesSub?.cancel();
    await _progressSub?.cancel();
    await _statsSub?.cancel();
    return super.close();
  }
}
