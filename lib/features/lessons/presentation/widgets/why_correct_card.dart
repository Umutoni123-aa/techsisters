import 'package:flutter/material.dart';
import 'package:techsisters/features/lessons/domain/entities/lesson.dart';
import 'package:techsisters/features/lessons/presentation/widgets/lessons_colors.dart';

/// "Why this answer is correct" card with the explanation and topic tags.
class WhyCorrectCard extends StatelessWidget {
  final Question question;
  const WhyCorrectCard({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: LessonsColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: LessonsColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: LessonsColors.greenSurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.menu_book,
                  size: 16,
                  color: LessonsColors.green,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Why this answer is correct',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: LessonsColors.ink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            question.explanation,
            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
              color: LessonsColors.slate,
            ),
          ),
          if (question.tags.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final tag in question.tags)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: LessonsColors.purpleSurface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: LessonsColors.purple,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
