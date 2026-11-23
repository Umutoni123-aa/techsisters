import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:techsisters/features/onboarding/data/models/learner_profile_model.dart';
import 'package:techsisters/features/onboarding/domain/entities/learner_profile.dart';

/// Reads and writes the onboarding answers on the `users/{uid}` document.
class OnboardingFirestoreDatasource {
  final FirebaseFirestore firestore;

  OnboardingFirestoreDatasource({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _userRef(String userId) =>
      firestore.collection('users').doc(userId);

  Stream<LearnerProfileModel> watchProfile(String userId) {
    return _userRef(userId)
        .snapshots()
        .map((doc) => LearnerProfileModel.fromMap(doc.data()));
  }

  Future<void> saveProfile(String userId, LearningGoal goal, SkillLevel level) {
    // merge keeps the XP and streak fields that live on the same document.
    return _userRef(userId)
        .set(LearnerProfileModel.toMap(goal, level), SetOptions(merge: true));
  }
}
