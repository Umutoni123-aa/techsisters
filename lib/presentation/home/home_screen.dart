import 'package:flutter/material.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.page),
      children: [
        const Text(
          'Muraho!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.slate900,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Continue your learning journey',
          style: TextStyle(color: AppColors.slate600),
        ),
        const SizedBox(height: AppSpacing.gap),
        _QuizBanner(),
        const SizedBox(height: AppSpacing.gap),
        const Text(
          'My Courses',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.medium),
        const AppCard(child: Text('Dart Basics')),
        const SizedBox(height: AppSpacing.medium),
        const AppCard(child: Text('AI Ethics')),
      ],
    );
  }
}

class _QuizBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.medium),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text(
        '5-Min AI Ethics Quiz',
        style: TextStyle(
          color: AppColors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}