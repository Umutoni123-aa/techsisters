part of 'onboarding_bloc.dart';

/// Where the learner is in the onboarding flow.
enum OnboardingStatus {
  /// Waiting for the saved profile to load.
  loading,

  /// No saved answers yet, so the questions are shown.
  needsOnboarding,

  /// Answered (or skipped); the app can open.
  ready,
}

class OnboardingState extends Equatable {
  final OnboardingStatus status;

  /// The answers saved in Firestore.
  final LearnerProfile profile;

  /// The choices made on screen but not yet saved.
  final LearningGoal? draftGoal;
  final SkillLevel? draftLevel;
  final bool saving;
  final bool skipped;

  /// One-shot message for a snackbar; [noticeId] makes repeats distinct.
  final String? notice;
  final int noticeId;

  const OnboardingState({
    this.status = OnboardingStatus.loading,
    this.profile = LearnerProfile.empty,
    this.draftGoal,
    this.draftLevel,
    this.saving = false,
    this.skipped = false,
    this.notice,
    this.noticeId = 0,
  });

  OnboardingState copyWith({
    OnboardingStatus? status,
    LearnerProfile? profile,
    LearningGoal? draftGoal,
    SkillLevel? draftLevel,
    bool? saving,
    bool? skipped,
    String? notice,
    int? noticeId,
  }) {
    return OnboardingState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      draftGoal: draftGoal ?? this.draftGoal,
      draftLevel: draftLevel ?? this.draftLevel,
      saving: saving ?? this.saving,
      skipped: skipped ?? this.skipped,
      // The notice is not carried over, so it shows only once.
      notice: notice,
      noticeId: noticeId ?? this.noticeId,
    );
  }

  @override
  List<Object?> get props => [
    status,
    profile,
    draftGoal,
    draftLevel,
    saving,
    skipped,
    notice,
    noticeId,
  ];
}
