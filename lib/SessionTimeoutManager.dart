/*
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
*/
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sudapedia/Database/DatabaseHelper.dart';
import 'package:sudapedia/SendOTP.dart';

class SessionTimeoutManager {
  static Timer? _logoutTimer;
  static Timer? _countdownTimer;
  static int _remainingTime = 30;

  static void startLogoutTimer(BuildContext context) {
    const sessionDuration = Duration(minutes: 30);
    const countdownDuration = Duration(seconds: 30);

    _logoutTimer?.cancel();
    _logoutTimer = Timer(sessionDuration - countdownDuration, () {
      _startCountdownTimer(context);
    });
  }

  static void _startCountdownTimer(BuildContext context) {
    _remainingTime = 30;

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        _remainingTime--;
      } else {
        timer.cancel();
        _logout(context);
      }
    });
  }

  static Future<void> _logout(BuildContext context) async {
    _logoutTimer?.cancel();
    _countdownTimer?.cancel();

    await DatabaseHelper().clearUserSession();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => SendOTP()),
      (Route<dynamic> route) => false,
    );
  }

  static void cancelTimers() {
    _logoutTimer?.cancel();
    _countdownTimer?.cancel();
  }
}

class SessionNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    SessionTimeoutManager.startLogoutTimer(navigator!.context);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    SessionTimeoutManager.startLogoutTimer(navigator!.context);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    SessionTimeoutManager.startLogoutTimer(navigator!.context);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    SessionTimeoutManager.startLogoutTimer(navigator!.context);
  }
}
