import 'package:flutter/material.dart';
import 'package:techsisters/features/lessons/domain/entities/course.dart';
import 'package:techsisters/features/lessons/presentation/widgets/lessons_colors.dart';

/// Catalog card for one course (Figma "06 Catalog").
class CourseCard extends StatelessWidget {
  final Course course;
  final int percent;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const CourseCard({
    super.key,
    required this.course,
    required this.percent,
    required this.onTap,
    required this.onLongPress,
  });

  bool get _isAi => course.category.toLowerCase().contains('ai');

  @override
  Widget build(BuildContext context) {
    final accent = _isAi ? LessonsColors.coral : LessonsColors.purple;
    final surface = _isAi
        ? LessonsColors.coralSurface
        : LessonsColors.purpleSurface;
    final done = percent >= 100;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LessonsColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _isAi ? Icons.smart_toy_outlined : Icons.code,
                    color: accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: LessonsColors.ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        course.description,
                        style: const TextStyle(
                          color: LessonsColors.slate,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _Meta(
                            icon: Icons.menu_book_outlined,
                            text: '${course.lessonCount} lessons',
                          ),
                          _Meta(
                            icon: Icons.schedule,
                            text: '${course.minutesPerLesson} min each',
                          ),
                          _Pill(
                            text: '~${course.sizeMb.toStringAsFixed(1)} MB',
                            color: LessonsColors.green,
                            background: LessonsColors.greenSurface,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _Pill(
                        text: course.category,
                        color: accent,
                        background: surface,
                      ),
                      if (percent > 0 && !done) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: percent / 100,
                                  minHeight: 6,
                                  color: accent,
                                  backgroundColor: LessonsColors.border,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$percent%',
                              style: const TextStyle(
                                fontSize: 12,
                                color: LessonsColors.slate,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: done
                        ? LessonsColors.greenSurface
                        : LessonsColors.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    done ? Icons.check_circle : Icons.cloud_outlined,
                    size: 18,
                    color: done ? LessonsColors.green : LessonsColors.slate,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Meta({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: LessonsColors.slate),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 12, color: LessonsColors.slate),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color color;
  final Color background;
  const _Pill({
    required this.text,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
