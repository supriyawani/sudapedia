import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sudapedia/Database/DatabaseHelper.dart';
import 'package:sudapedia/SendOTP.dart';

class SessionTimeoutManager {
  static Timer? _logoutTimer;
  static Timer? _countdownTimer;
  static int _remainingTime = 24;

  static void startLogoutTimer(BuildContext context) {
    const sessionDuration = Duration(hours: 24);
    const countdownDuration = Duration(seconds: 30);

    _logoutTimer?.cancel();
    _logoutTimer = Timer(sessionDuration - countdownDuration, () {
      _startCountdownTimer(context);
    });
  }

  static void resetLogoutTimer(BuildContext context) {
    startLogoutTimer(context);
  }

  static void _startCountdownTimer(BuildContext context) {
    _remainingTime = 24;

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(Duration(hours: 1), (timer) {
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
