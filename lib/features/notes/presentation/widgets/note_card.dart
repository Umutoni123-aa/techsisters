import 'package:flutter/material.dart';
import 'package:techsisters/core/theme/app_theme.dart';
import 'package:techsisters/core/widgets/app_card.dart';

import '../../domain/entities/note.dart';

/// One note in the list: title, a short preview, when it was last edited,
/// and a "Lesson note" tag when it is linked to a lesson.
class NoteCard extends StatelessWidget {
  const NoteCard({super.key, required this.note, required this.onTap});

  final Note note;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            note.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.slate900,
            ),
          ),
          if (note.content.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              note.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.slate600, height: 1.4),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.schedule, size: 14, color: AppColors.slate500),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Edited ${formatNoteDate(note.updatedAt)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.slate500,
                  ),
                ),
              ),
              if (note.lessonId != null) const _LessonTag(),
            ],
          ),
        ],
      ),
    );
  }
}

class _LessonTag extends StatelessWidget {
  const _LessonTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.violetSurface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'Lesson note',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// Formats a date as "18 Nov 2026" without needing the intl package.
String formatNoteDate(DateTime date) {
  return '${date.day} ${_months[date.month - 1]} ${date.year}';
}
