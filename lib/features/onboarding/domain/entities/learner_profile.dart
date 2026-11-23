import 'package:equatable/equatable.dart';

/// What the learner mainly wants to study.
enum LearningGoal { coding, ai, both }

/// How much experience the learner already has.
enum SkillLevel { beginner, some, confident }

/// The answers a learner gives during onboarding. They are saved on the
/// learner's `users/{uid}` document and used to pick a "Start here" course.
class LearnerProfile extends Equatable {
  final LearningGoal? goal;
  final SkillLevel? level;

  const LearnerProfile({this.goal, this.level});

  /// A profile with no answers, used when onboarding is skipped.
  static const LearnerProfile empty = LearnerProfile();

  /// True once both questions have been answered.
  bool get isComplete => goal != null && level != null;

  @override
  List<Object?> get props => [goal, level];
}
