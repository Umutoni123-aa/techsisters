import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState extends Equatable {
  final bool darkMode;
  final bool notifications;
  final bool wifiOnlyDownloads;

  const SettingsState({
    this.darkMode = false,
    this.notifications = true,
    this.wifiOnlyDownloads = true,
  });

  SettingsState copyWith({
    bool? darkMode,
    bool? notifications,
    bool? wifiOnlyDownloads,
  }) {
    return SettingsState(
      darkMode: darkMode ?? this.darkMode,
      notifications: notifications ?? this.notifications,
      wifiOnlyDownloads: wifiOnlyDownloads ?? this.wifiOnlyDownloads,
    );
  }

  @override
  List<Object> get props => [darkMode, notifications, wifiOnlyDownloads];
}

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(const SettingsState());

  static const _darkKey = 'dark_mode';
  static const _notificationsKey = 'notifications';
  static const _wifiKey = 'wifi_only_downloads';

  /// When the app starts, reads the saved settings
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    emit(SettingsState(
      darkMode: prefs.getBool(_darkKey) ?? false,
      notifications: prefs.getBool(_notificationsKey) ?? true,
      wifiOnlyDownloads: prefs.getBool(_wifiKey) ?? true,
    ));
  }

  Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkKey, value);
    emit(state.copyWith(darkMode: value));
  }

  Future<void> setNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, value);
    emit(state.copyWith(notifications: value));
  }

  Future<void> setWifiOnlyDownloads(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_wifiKey, value);
    emit(state.copyWith(wifiOnlyDownloads: value));
  }
}