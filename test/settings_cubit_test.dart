import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techsisters/presentation/settings/settings_cubit.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('setDarkMode saves the value and updates the state', () async {
    final cubit = SettingsCubit();

    await cubit.setDarkMode(true);

    expect(cubit.state.darkMode, true);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('dark_mode'), true);

    await cubit.close();
  });

  test('load restores the saved settings', () async {
    SharedPreferences.setMockInitialValues({
      'dark_mode': true,
      'notifications': false,
    });
    final cubit = SettingsCubit();

    await cubit.load();

    expect(cubit.state.darkMode, true);
    expect(cubit.state.notifications, false);

    await cubit.close();
  });

  test('settings cubit saves and restores all settings', () async {
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