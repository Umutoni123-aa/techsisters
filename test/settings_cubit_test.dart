import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techsisters/presentation/settings/settings_cubit.dart';

void main() {
  test('settings cubit saves and restores all settings', () async {
    SharedPreferences.setMockInitialValues({});
    final cubit = SettingsCubit();

    await cubit.setDarkMode(true);
    await cubit.setNotifications(false);
    await cubit.setWifiOnlyDownloads(false);

    final restartedCubit = SettingsCubit();
    await restartedCubit.load();

    expect(restartedCubit.state.darkMode, true);
    expect(restartedCubit.state.notifications, false);
    expect(restartedCubit.state.wifiOnlyDownloads, false);

    await cubit.close();
    await restartedCubit.close();
  });
}