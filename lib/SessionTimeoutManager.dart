import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _loginTimeKey = 'login_time';
  static const String _tokenKey = 'user_token';

  static Future<void> setLoginTime(DateTime loginTime, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_loginTimeKey, loginTime.toIso8601String());
    await prefs.setString(_tokenKey, token);
  }

  static Future<DateTime?> getLoginTime() async {
    final prefs = await SharedPreferences.getInstance();
    final loginTimeString = prefs.getString(_loginTimeKey);
    if (loginTimeString == null) return null;
    return DateTime.parse(loginTimeString);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<bool> isUserLoggedIn() async {
    final token = await getToken();
    if (token == null) return false;

    final loginTime = await getLoginTime();
    if (loginTime == null) return false;

    final currentTime = DateTime.now();
    final difference = currentTime.difference(loginTime);
    return difference.inMinutes < 30;
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loginTimeKey);
    await prefs.remove(_tokenKey);
  }
}
