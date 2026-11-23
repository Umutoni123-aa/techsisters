import 'package:flutter/material.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../settings/settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
        const CircleAvatar(
          radius: 40,
          backgroundColor: AppColors.primary,
          child: Text(
            'SN',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.medium),
        const Text(
          _name,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.gap),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.medium,
          crossAxisSpacing: AppSpacing.medium,
          childAspectRatio: 1.6,
          children: [
            for (final stat in _stats)
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
                      style: const TextStyle(color: AppColors.slate600),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}