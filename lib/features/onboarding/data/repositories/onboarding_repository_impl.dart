import 'package:techsisters/features/onboarding/data/datasources/onboarding_firestore_datasource.dart';
import 'package:techsisters/features/onboarding/domain/entities/learner_profile.dart';
import 'package:techsisters/features/onboarding/domain/repositories/onboarding_repository.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingFirestoreDatasource datasource;

  OnboardingRepositoryImpl(this.datasource);

  @override
  Stream<LearnerProfile> watchProfile(String userId) =>
      datasource.watchProfile(userId);

  @override
  Future<void> saveProfile({
    required String userId,
    required LearningGoal goal,
    required SkillLevel level,
  }) => datasource.saveProfile(userId, goal, level);
}
