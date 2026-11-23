import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../settings/settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  /// Signed-in user details; placeholders are shown when they are null.
  final String? name;
  final String? email;

  /// Called by the "Log out" button. The button is hidden when null.
  final VoidCallback? onLogout;

  /// The four numbers in the stats grid (label, value). Placeholder numbers
  /// are shown when null.
  final List<(String, String)>? stats;

  /// Opens the badges and certificates screen. The button is hidden when null.
  final VoidCallback? onOpenAchievements;

  const ProfileScreen({
    super.key,
    this.name,
    this.email,
    this.onLogout,
    this.stats,
    this.onOpenAchievements,
  });

  // Temporary data.
  static const _name = 'Student Name';
  static const _stats = [
    ('Lessons done', '24'),
    ('Day streak', '5'),
    ('Badges', '4'),
    ('Points', '440'),
  ];

  @override
  Widget build(BuildContext context) {
    final displayName = (name != null && name!.trim().isNotEmpty)
        ? name!.trim()
        : _name;
    final initials = displayName
        .split(' ')
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.page),
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => Scaffold(
                  appBar: AppBar(title: const Text('Settings')),
                  body: const SafeArea(child: SettingsScreen()),
                ),
              ),
            ),
          ),
        ),
        CircleAvatar(
          radius: 40,
          backgroundColor: AppColors.primary,
          child: Text(
            initials,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.medium),
        Text(
          displayName,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
        if (email != null)
          Text(
            email!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.slate600),
          ),
        const SizedBox(height: AppSpacing.gap),
        GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: AppSpacing.medium,
            crossAxisSpacing: AppSpacing.medium,
            mainAxisExtent: 120, // fixed height, so the text always fits
          ),
          children: [
            for (final stat in stats ?? _stats)
              AppCard(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      stat.$2,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      stat.$1,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.slate600),
                    ),
                  ],
                ),
              ),
          ],
        ),
        if (onOpenAchievements != null) ...[
          const SizedBox(height: AppSpacing.gap),
          OutlinedButton.icon(
            onPressed: onOpenAchievements,
            icon: const Icon(Icons.workspace_premium_outlined),
            label: const Text('Badges & certificates'),
          ),
        ],
        if (onLogout != null) ...[
          const SizedBox(height: AppSpacing.medium),
          OutlinedButton.icon(
            onPressed: onLogout,
            icon: const Icon(Icons.logout),
            label: const Text('Log out'),
          ),
        ],
      ],
    );
  }
}
