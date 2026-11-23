import 'package:techsisters/features/onboarding/domain/entities/learner_profile.dart';
import 'package:techsisters/features/onboarding/domain/repositories/onboarding_repository.dart';

/// Streams the learner's saved onboarding answers.
class WatchLearnerProfileUseCase {
  final OnboardingRepository repository;
  WatchLearnerProfileUseCase(this.repository);

  Stream<LearnerProfile> call(String userId) => repository.watchProfile(userId);
}

/// Saves the learner's goal and skill level.
class SaveLearnerProfileUseCase {
  final OnboardingRepository repository;
  SaveLearnerProfileUseCase(this.repository);

  Future<void> call({
    required String userId,
    required LearningGoal goal,
    required SkillLevel level,
  }) {
    return repository.saveProfile(userId: userId, goal: goal, level: level);
  }
}
