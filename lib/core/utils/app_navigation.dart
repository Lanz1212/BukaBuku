import 'dart:async';
import 'package:flutter/material.dart';

/// Global navigation and messaging helper to prevent unmounted context errors
/// and ensure SnackBar actions can navigate safely from anywhere in the app.
class AppNavigation {
  AppNavigation._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static BuildContext? get currentContext => navigatorKey.currentContext;

  static Timer? _snackBarTimer;

  static void hideCurrentSnackBar() {
    _snackBarTimer?.cancel();
    _snackBarTimer = null;
    scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
  }

  static void removeCurrentSnackBar() {
    _snackBarTimer?.cancel();
    _snackBarTimer = null;
    scaffoldMessengerKey.currentState?.removeCurrentSnackBar();
  }

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? showSnackBar(
    SnackBar snackBar, {
    Duration? autoDismissDuration,
  }) {
    _snackBarTimer?.cancel();
    scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
    final controller = scaffoldMessengerKey.currentState?.showSnackBar(snackBar);

    final duration = autoDismissDuration ?? snackBar.duration;
    _snackBarTimer = Timer(duration, () {
      scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
    });

    return controller;
  }

  static Future<T?>? push<T extends Object?>(Route<T> route) {
    return navigatorKey.currentState?.push<T>(route);
  }
}


