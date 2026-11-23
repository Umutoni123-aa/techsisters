part of 'lessons_bloc.dart';

abstract class LessonsEvent extends Equatable {
  const LessonsEvent();

  @override
  List<Object?> get props => [];
}

/// Start listening to courses, the user's progress and the user's stats.
class LoadLessonsEvent extends LessonsEvent {
  final String userId;
  const LoadLessonsEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Internal: new data arrived from Firestore.
class LessonsDataChangedEvent extends LessonsEvent {
  final List<Course> courses;
  final Map<String, LessonProgress> progress;
  final UserStats stats;
  const LessonsDataChangedEvent(this.courses, this.progress, this.stats);

  @override
  List<Object?> get props => [courses, progress, stats];
}

/// Internal: a Firestore stream failed.
class LessonsFailedEvent extends LessonsEvent {
  final String message;
  const LessonsFailedEvent(this.message);

  @override
  List<Object?> get props => [message];
}

/// Re-read which lesson videos are saved on the phone (for the
/// "Downloaded" filter). Sent on start and after leaving a lesson.
class RefreshDownloadsEvent extends LessonsEvent {
  const RefreshDownloadsEvent();
}

class SearchChangedEvent extends LessonsEvent {
  final String query;
  const SearchChangedEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class CategorySelectedEvent extends LessonsEvent {
  final String category;
  const CategorySelectedEvent(this.category);

  @override
  List<Object?> get props => [category];
}

class ResetProgressEvent extends LessonsEvent {
  final String courseId;
  const ResetProgressEvent(this.courseId);

  @override
  List<Object?> get props => [courseId];
}
