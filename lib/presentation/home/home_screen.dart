import 'package:flutter/material.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../features/lessons/domain/entities/user_stats.dart';
import '../../features/lessons/presentation/bloc/lessons_bloc.dart';

class HomeScreen extends StatelessWidget {
  /// The signed-in user's name. Only the first name is shown.
  final String? name;

  /// The real lessons data. Placeholders are shown when this is null.
  final LessonsLoaded? lessons;

  const HomeScreen({super.key, this.name, this.lessons});

  String get _firstName {
    final text = name?.trim() ?? '';
    return text.isEmpty ? '' : text.split(' ').first;
  }

  @override
  Widget build(BuildContext context) {
    final data = lessons;
    final greeting = _firstName.isEmpty ? 'Muraho!' : 'Muraho, $_firstName!';

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.page),
      children: [
        Text(
          greeting,
          style: const TextStyle(
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
        if (data == null)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.gap),
              child: CircularProgressIndicator(),
            ),
          )
        else
          _StatsBanner(
            level: data.stats.level,
            xpInLevel: data.stats.xpInLevel,
            streak: data.stats.streak,
          ),
        const SizedBox(height: AppSpacing.gap),
        const Text(
          'My Courses',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.medium),
        if (data == null)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.gap),
              child: CircularProgressIndicator(),
            ),
          )
        else if (data.courses.isEmpty)
          const Text(
            'No courses yet.',
            style: TextStyle(color: AppColors.slate600),
          )
        else
          for (final course in data.courses.take(3)) ...[
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: data.percentFor(course) / 100,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${data.percentFor(course)}% done',
                    style: const TextStyle(color: AppColors.slate600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.medium),
          ],
      ],
    );
  }
}

class _StatsBanner extends StatelessWidget {
  final int level;
  final int xpInLevel;
  final int streak;

  const _StatsBanner({
    required this.level,
    required this.xpInLevel,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.medium),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Level $level',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Icon(
                Icons.local_fire_department,
                color: AppColors.white,
              ),
              const SizedBox(width: 4),
              Text(
                '$streak day streak',
                style: const TextStyle(color: AppColors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: xpInLevel / UserStats.xpPerLevel,
            color: AppColors.white,
            backgroundColor: Colors.white24,
          ),
          const SizedBox(height: 6),
          Text(
            '$xpInLevel / ${UserStats.xpPerLevel} XP to next level',
            style: const TextStyle(color: AppColors.white),
          ),
        ],
      ),
    );
  }
}