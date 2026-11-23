import 'package:equatable/equatable.dart';

/// A course in the top-level `courses` Firestore collection.
class Course extends Equatable {
  final String id;
  final String title;
  final String description;

  /// Used for the catalog filter chips, e.g. "AI Literacy" or "Coding".
  final String category;
  final int lessonCount;
  final int minutesPerLesson;
  final double sizeMb;
  final int order;

  const Course({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.lessonCount,
    required this.minutesPerLesson,
    required this.sizeMb,
    required this.order,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    category,
    lessonCount,
    minutesPerLesson,
    sizeMb,
    order,
  ];
}
