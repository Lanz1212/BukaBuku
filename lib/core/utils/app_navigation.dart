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

  static void hideCurrentSnackBar() {
    scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
  }

  static void removeCurrentSnackBar() {
    scaffoldMessengerKey.currentState?.removeCurrentSnackBar();
  }

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? showSnackBar(
    SnackBar snackBar,
  ) {
    scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
    return scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
  }

  static Future<T?>? push<T extends Object?>(Route<T> route) {
    return navigatorKey.currentState?.push<T>(route);
  }
}

