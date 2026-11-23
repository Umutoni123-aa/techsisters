import 'package:flutter/material.dart';
import 'package:techsisters/features/lessons/domain/entities/user_stats.dart';
import 'package:techsisters/features/lessons/presentation/widgets/lessons_colors.dart';

/// "Level 3 — Learner  440 / 600 XP" bar shown on the success sheet.
class OverallProgressCard extends StatelessWidget {
  final UserStats stats;

  const OverallProgressCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: LessonsColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LessonsColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Level ${stats.level} — Learner',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: LessonsColors.slate,
                  ),
                ),
              ),
              Text(
                '${stats.xpInLevel} / ${UserStats.xpPerLevel} XP',
                style: const TextStyle(
                  fontSize: 12,
                  color: LessonsColors.slate,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: stats.xpInLevel / UserStats.xpPerLevel,
              minHeight: 6,
              color: LessonsColors.purple,
              backgroundColor: LessonsColors.border,
            ),
          ),
        ],
      ),
    );
  }
}
