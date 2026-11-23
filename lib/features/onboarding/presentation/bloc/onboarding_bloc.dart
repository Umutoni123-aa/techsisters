import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:techsisters/features/onboarding/domain/entities/learner_profile.dart';
import 'package:techsisters/features/onboarding/domain/usecases/onboarding_usecases.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';

/// Decides whether the learner still has to answer the onboarding questions,
/// and saves the answers when they do.
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final String userId;
  final WatchLearnerProfileUseCase watchProfile;
  final SaveLearnerProfileUseCase saveProfile;

  OnboardingBloc({
    required this.userId,
    required this.watchProfile,
    required this.saveProfile,
  }) : super(const OnboardingState()) {
    on<LoadProfileEvent>(_onLoad);
    on<GoalChosenEvent>((e, emit) => emit(state.copyWith(draftGoal: e.goal)));
    on<LevelChosenEvent>(
      (e, emit) => emit(state.copyWith(draftLevel: e.level)),
    );
    on<SubmitProfileEvent>(_onSubmit);
    on<SkipOnboardingEvent>(
      (e, emit) =>
          emit(state.copyWith(skipped: true, status: OnboardingStatus.ready)),
    );
  }

  /// Follows the saved profile. A complete profile (or a skip) opens the app.
  Future<void> _onLoad(LoadProfileEvent event, Emitter<OnboardingState> emit) {
    return emit.forEach<LearnerProfile>(
      watchProfile(userId),
      onData: (profile) => state.copyWith(
        profile: profile,
        status: profile.isComplete || state.skipped
            ? OnboardingStatus.ready
            : OnboardingStatus.needsOnboarding,
      ),
      // If the profile cannot be read, let the learner in rather than
      // leaving them stuck on a loading screen.
      onError: (error, _) => state.copyWith(
        status: OnboardingStatus.ready,
        notice: 'Could not load your learning profile: $error',
        noticeId: state.noticeId + 1,
      ),
    );
  }

  Future<void> _onSubmit(
    SubmitProfileEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    final goal = state.draftGoal;
    final level = state.draftLevel;

    // Validation: both questions must be answered.
    if (goal == null || level == null) {
      emit(
        state.copyWith(
          notice: 'Please choose a goal and your level.',
          noticeId: state.noticeId + 1,
        ),
      );
      return;
    }

    emit(state.copyWith(saving: true));
    try {
      await saveProfile(userId: userId, goal: goal, level: level);
      // The watched profile now becomes complete and moves us to "ready".
      emit(state.copyWith(saving: false));
    } catch (error) {
      emit(
        state.copyWith(
          saving: false,
          notice: 'Could not save your answers: $error',
          noticeId: state.noticeId + 1,
        ),
      );
    }
  }
}
