import 'package:flutter/material.dart';
import 'package:techsisters/features/lessons/domain/entities/lesson.dart';
import 'package:techsisters/features/lessons/domain/entities/user_stats.dart';
import 'package:techsisters/features/lessons/presentation/widgets/lessons_colors.dart';
import 'package:techsisters/features/lessons/presentation/widgets/overall_progress_card.dart';
import 'package:techsisters/features/lessons/presentation/widgets/why_correct_card.dart';

/// The "Lesson Complete!" bottom sheet (Figma "08 Lesson Success").
class LessonCompleteSheet extends StatelessWidget {
  /// The last question of the lesson, whose explanation is shown.
  final Question lastQuestion;
  final UserStats stats;
  final int pointsEarned;
  final int totalQuestions;
  final int firstTryCorrect;
  final bool isLastLesson;
  final VoidCallback onNext;

  const LessonCompleteSheet({
    super.key,
    required this.lastQuestion,
    required this.stats,
    required this.pointsEarned,
    required this.totalQuestions,
    required this.firstTryCorrect,
    required this.isLastLesson,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: LessonsColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [LessonsColors.purpleLight, LessonsColors.purple],
                    ),
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: LessonsColors.coral,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text(
              'Lesson Complete!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: LessonsColors.ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$firstTryCorrect of $totalQuestions correct on the first try',
              style: const TextStyle(fontSize: 13, color: LessonsColors.slate),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                if (pointsEarned > 0)
                  _Chip(
                    icon: Icons.star,
                    text: '+$pointsEarned Points',
                    color: LessonsColors.purple,
                    background: LessonsColors.purpleSurface,
                  ),
                _Chip(
                  icon: Icons.local_fire_department,
                  text: stats.streak > 1
                      ? '${stats.streak}-Day Streak!'
                      : 'Streak Started!',
                  color: LessonsColors.orange,
                  background: LessonsColors.orangeSurface,
                ),
              ],
            ),
            const SizedBox(height: 16),
            WhyCorrectCard(question: lastQuestion),
            const SizedBox(height: 14),
            OverallProgressCard(stats: stats),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: LessonsColors.purple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: onNext,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isLastLesson ? 'Finish' : 'Next Lesson',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final Color background;

  const _Chip({
    required this.icon,
    required this.text,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
