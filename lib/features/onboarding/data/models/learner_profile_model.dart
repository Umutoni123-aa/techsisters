import 'package:techsisters/features/onboarding/domain/entities/learner_profile.dart';

/// Converts a [LearnerProfile] to and from the fields stored in Firestore.
/// The enums are stored by name, e.g. `learningGoal: "coding"`.
class LearnerProfileModel extends LearnerProfile {
  const LearnerProfileModel({super.goal, super.level});

  /// Reads the profile from a `users/{uid}` document. Unknown or missing
  /// values become null, so an old or empty document gives an empty profile.
  factory LearnerProfileModel.fromMap(Map<String, dynamic>? map) {
    return LearnerProfileModel(
      goal: _byName(LearningGoal.values, map?['learningGoal']),
      level: _byName(SkillLevel.values, map?['skillLevel']),
    );
  }

  /// The fields to merge into the user document.
  static Map<String, dynamic> toMap(LearningGoal goal, SkillLevel level) => {
    'learningGoal': goal.name,
    'skillLevel': level.name,
  };

  static T? _byName<T extends Enum>(List<T> values, Object? name) {
    for (final value in values) {
      if (value.name == name) return value;
    }
    return null;
  }
}
