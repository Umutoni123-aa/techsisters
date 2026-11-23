part of 'onboarding_bloc.dart';

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

/// Start listening to the learner's saved answers.
class LoadProfileEvent extends OnboardingEvent {
  const LoadProfileEvent();
}

class GoalChosenEvent extends OnboardingEvent {
  final LearningGoal goal;
  const GoalChosenEvent(this.goal);

  @override
  List<Object?> get props => [goal];
}

class LevelChosenEvent extends OnboardingEvent {
  final SkillLevel level;
  const LevelChosenEvent(this.level);

  @override
  List<Object?> get props => [level];
}

/// The learner pressed "Continue".
class SubmitProfileEvent extends OnboardingEvent {
  const SubmitProfileEvent();
}

/// The learner pressed "Skip for now"; nothing is saved.
class SkipOnboardingEvent extends OnboardingEvent {
  const SkipOnboardingEvent();
}
