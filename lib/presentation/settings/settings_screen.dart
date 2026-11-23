import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import 'settings_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final cubit = context.read<SettingsCubit>();
        return ListView(
          padding: const EdgeInsets.all(AppSpacing.page),
          children: [
            const Text(
              'Settings',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.gap),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  SwitchListTile(
                    activeThumbColor: AppColors.primary,
                    title: const Text('Dark mode'),
                    subtitle: const Text('Use a darker look'),
                    value: state.darkMode,
                    onChanged: cubit.setDarkMode,
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    activeThumbColor: AppColors.primary,
                    title: const Text('Notifications'),
                    subtitle: const Text('Daily learning reminders'),
                    value: state.notifications,
                    onChanged: cubit.setNotifications,
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    activeThumbColor: AppColors.primary,
                    title: const Text('Download on Wi-Fi only'),
                    subtitle: const Text('Save your mobile data'),
                    value: state.wifiOnlyDownloads,
                    onChanged: cubit.setWifiOnlyDownloads,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
