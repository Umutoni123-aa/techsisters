part of 'lessons_bloc.dart';

abstract class LessonsState extends Equatable {
  const LessonsState();

  @override
  List<Object?> get props => [];
}

class LessonsInitial extends LessonsState {
  const LessonsInitial();
}

class LessonsLoading extends LessonsState {
  const LessonsLoading();
}

class LessonsLoaded extends LessonsState {
  static const String allCategory = 'All';

  final List<Course> courses;
  final Map<String, LessonProgress> progress;
  final UserStats stats;
  final String query;
  final String category;

  /// One-shot message for a snackbar (e.g. a failed write); null otherwise.
  final String? message;
  final int messageId;

  const LessonsLoaded({
    required this.courses,
    required this.progress,
    required this.stats,
    this.query = '',
    this.category = allCategory,
    this.message,
    this.messageId = 0,
  });

  /// Filter chips: "All" plus every category found in the data.
  List<String> get categories => [
    allCategory,
    ...{for (final c in courses) c.category},
  ];

  /// Courses matching the search text and the selected chip.
  List<Course> get visibleCourses {
    final needle = query.trim().toLowerCase();
    return courses.where((c) {
      final inCategory = category == allCategory || c.category == category;
      final inSearch =
          needle.isEmpty ||
          c.title.toLowerCase().contains(needle) ||
          c.description.toLowerCase().contains(needle);
      return inCategory && inSearch;
    }).toList();
  }

  int completedLessonsFor(String courseId) =>
      progress[courseId]?.completedLessons ?? 0;

  int percentFor(Course course) =>
      progress[course.id]?.percentOf(course.lessonCount) ?? 0;

  LessonsLoaded copyWith({
    List<Course>? courses,
    Map<String, LessonProgress>? progress,
    UserStats? stats,
    String? query,
    String? category,
    String? message,
    int? messageId,
  }) {
    return LessonsLoaded(
      courses: courses ?? this.courses,
      progress: progress ?? this.progress,
      stats: stats ?? this.stats,
      query: query ?? this.query,
      category: category ?? this.category,
      // The message is not carried over, so it shows only once.
      message: message,
      messageId: messageId ?? this.messageId,
    );
  }

  @override
  List<Object?> get props => [
    courses,
    progress,
    stats,
    query,
    category,
    message,
    messageId,
  ];
}

class LessonsError extends LessonsState {
  final String message;
  const LessonsError(this.message);

  @override
  List<Object?> get props => [message];
}
