import 'package:techsisters/features/onboarding/domain/entities/learner_profile.dart';

/// Contract for reading and saving a learner's onboarding answers.
abstract class OnboardingRepository {
  /// Live profile of [userId]. Emits an empty profile if nothing is saved yet.
  Stream<LearnerProfile> watchProfile(String userId);

  /// Saves the learner's answers on their user document.
  Future<void> saveProfile({
    required String userId,
    required LearningGoal goal,
    required SkillLevel level,
  });
}
