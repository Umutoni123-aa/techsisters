import 'package:shared_preferences/shared_preferences.dart';

class LocalAuthDataSource {
  static const String _keyUID = 'user_uid';
  static const String _keyEmail = 'user_email';
  static const String _keyDisplayName = 'user_display_name';
  static const String _keyPhotoUrl = 'user_photo_url';
  static const String _keyEmailVerified = 'user_email_verified';

  final SharedPreferences sharedPreferences;

  LocalAuthDataSource(this.sharedPreferences);

  Future<void> saveUserSession({
    required String uid,
    required String email,
    String? displayName,
    String? photoUrl,
    required bool emailVerified,
  }) async {
    await sharedPreferences.setString(_keyUID, uid);
    await sharedPreferences.setString(_keyEmail, email);
    if (displayName != null) {
      await sharedPreferences.setString(_keyDisplayName, displayName);
    }
    if (photoUrl != null) {
      await sharedPreferences.setString(_keyPhotoUrl, photoUrl);
    }
    await sharedPreferences.setBool(_keyEmailVerified, emailVerified);
  }

  Future<bool> isUserLoggedIn() async {
    return sharedPreferences.containsKey(_keyUID);
  }

  String? getCachedUID() {
    return sharedPreferences.getString(_keyUID);
  }

  String? getCachedEmail() {
    return sharedPreferences.getString(_keyEmail);
  }

  String? getCachedDisplayName() {
    return sharedPreferences.getString(_keyDisplayName);
  }

  String? getCachedPhotoUrl() {
    return sharedPreferences.getString(_keyPhotoUrl);
  }

  bool getCachedEmailVerified() {
    return sharedPreferences.getBool(_keyEmailVerified) ?? false;
  }

  Future<void> clearUserSession() async {
    await sharedPreferences.remove(_keyUID);
    await sharedPreferences.remove(_keyEmail);
    await sharedPreferences.remove(_keyDisplayName);
    await sharedPreferences.remove(_keyPhotoUrl);
    await sharedPreferences.remove(_keyEmailVerified);
  }
}
