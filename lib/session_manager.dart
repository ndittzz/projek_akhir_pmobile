import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const _isLoggedInKey = 'is_logged_in';
  static const _currentUserKey = 'current_user';

  static Future<void> setLoggedIn(bool value, {String? username}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, value);
    if (username != null) {
      await prefs.setString(_currentUserKey, username);
    }
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  static Future<String?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentUserKey);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_currentUserKey);
  }
}
