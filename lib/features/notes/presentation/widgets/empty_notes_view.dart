import 'package:flutter/material.dart';
import 'package:techsisters/core/theme/app_spacing.dart';
import 'package:techsisters/core/theme/app_theme.dart';

/// Shown when the learner has no notes yet.
class EmptyNotesView extends StatelessWidget {
  const EmptyNotesView({super.key});

  @override
  Widget build(BuildContext context) {
    // Scrollable so the message never overflows in landscape.
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.page),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.violetSurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.edit_note,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.medium),
            const Text(
              'No notes yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.slate900,
              ),
            ),
            const SizedBox(height: AppSpacing.small),
            const Text(
              'Save what you learn so you can review it later. '
              'Tap "New note" to write your first one.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.slate600, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
