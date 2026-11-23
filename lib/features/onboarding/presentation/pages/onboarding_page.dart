import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:techsisters/core/theme/app_spacing.dart';
import 'package:techsisters/core/theme/app_theme.dart';
import 'package:techsisters/core/widgets/primary_button.dart';
import 'package:techsisters/features/onboarding/domain/entities/learner_profile.dart';
import 'package:techsisters/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:techsisters/features/onboarding/presentation/widgets/choice_card.dart';

/// Shown once after a learner's first sign-in. Two questions (goal and skill
/// level) decide which course is suggested as "Start here". It can be skipped.
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  // The answers shown on screen: label, short description and icon.
  static const _goals = [
    (LearningGoal.coding, 'Coding', 'Learn to write programs', Icons.code),
    (
      LearningGoal.ai,
      'AI literacy',
      'Understand how AI works and how to use it well',
      Icons.smart_toy_outlined,
    ),
    (LearningGoal.both, 'A bit of both', 'Coding and AI', Icons.auto_awesome),
  ];

  static const _levels = [
    (SkillLevel.beginner, 'Beginner', "I'm just starting", Icons.flag_outlined),
    (SkillLevel.some, 'Some experience', 'I know a little', Icons.trending_up),
    (
      SkillLevel.confident,
      'Confident',
      'I can already build small things',
      Icons.rocket_launch_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<OnboardingBloc>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocConsumer<OnboardingBloc, OnboardingState>(
          // Show validation and save errors as a snackbar.
          listenWhen: (p, c) => c.notice != null && c.noticeId != p.noticeId,
          listener: (context, state) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.notice!)));
          },
          builder: (context, state) {
            // Scrolls so small phones and landscape never overflow.
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.page),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Let's set up your path",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.slate900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Two quick questions help us pick the best place to start.',
                    style: TextStyle(color: AppColors.slate600),
                  ),
                  const SizedBox(height: AppSpacing.gap),
                  const _SectionTitle('What do you want to learn?'),
                  for (final goal in _goals)
                    ChoiceCard(
                      icon: goal.$4,
                      title: goal.$2,
                      subtitle: goal.$3,
                      selected: state.draftGoal == goal.$1,
                      onTap: state.saving
                          ? null
                          : () => bloc.add(GoalChosenEvent(goal.$1)),
                    ),
                  const SizedBox(height: AppSpacing.medium),
                  const _SectionTitle("What's your level?"),
                  for (final level in _levels)
                    ChoiceCard(
                      icon: level.$4,
                      title: level.$2,
                      subtitle: level.$3,
                      selected: state.draftLevel == level.$1,
                      onTap: state.saving
                          ? null
                          : () => bloc.add(LevelChosenEvent(level.$1)),
                    ),
                  const SizedBox(height: AppSpacing.medium),
                  PrimaryButton(
                    label: state.saving ? 'Saving...' : 'Continue',
                    icon: Icons.arrow_forward,
                    onPressed: state.saving
                        ? null
                        : () => bloc.add(const SubmitProfileEvent()),
                  ),
                  const SizedBox(height: AppSpacing.small),
                  Center(
                    child: TextButton(
                      onPressed: state.saving
                          ? null
                          : () => bloc.add(const SkipOnboardingEvent()),
                      child: const Text('Skip for now'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// A bold heading above a group of answers.
class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.slate900,
        ),
      ),
    );
  }
}
