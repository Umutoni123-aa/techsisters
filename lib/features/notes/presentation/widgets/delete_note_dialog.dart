import 'package:flutter/material.dart';
import 'package:techsisters/core/theme/app_theme.dart';

/// Asks the learner to confirm before a note is deleted.
/// Returns `true` only when they tap "Delete".
Future<bool> showDeleteNoteDialog(BuildContext context, String title) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Delete note?'),
      content: Text(
        '"$title" will be removed permanently.',
        style: const TextStyle(color: AppColors.slate600),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.coral,
            foregroundColor: AppColors.white,
          ),
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
