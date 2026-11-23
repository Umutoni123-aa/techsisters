import 'package:equatable/equatable.dart';

/// A badge or milestone a learner can earn, for example "First step".
class Achievement extends Equatable {
  /// Stable id, also used to choose the badge icon on screen.
  final String id;
  final String title;
  final String description;
  final bool earned;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.earned,
  });

  @override
  List<Object?> get props => [id, title, description, earned];
}

/// A certificate for a course the learner has finished.
class Certificate extends Equatable {
  final String courseId;
  final String courseTitle;

  /// When the last lesson of the course was finished.
  final DateTime completedOn;

  const Certificate({
    required this.courseId,
    required this.courseTitle,
    required this.completedOn,
  });

  @override
  List<Object?> get props => [courseId, courseTitle, completedOn];
}

/// Everything the Profile and Achievements screens need in one object.
class AchievementSummary extends Equatable {
  final int lessonsDone;
  final int streak;
  final int points;
  final List<Achievement> achievements;
  final List<Certificate> certificates;

  const AchievementSummary({
    required this.lessonsDone,
    required this.streak,
    required this.points,
    required this.achievements,
    required this.certificates,
  });

  /// How many badges have been earned so far.
  int get badgesEarned => achievements.where((a) => a.earned).length;

  @override
  List<Object?> get props => [
    lessonsDone,
    streak,
    points,
    achievements,
    certificates,
  ];
}
