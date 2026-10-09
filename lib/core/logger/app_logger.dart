import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Minimal structured logger. Debug output goes to dart:developer; the
/// Crashlytics phase adds a release sink here (single choke point).
class AppLogger {
  const AppLogger(this.name);

  final String name;

  void debug(String message) => _log(message, level: 500);

  void info(String message) => _log(message, level: 800);

  void warning(String message, [Object? error]) =>
      _log(message, level: 900, error: error);

  void error(String message, [Object? error, StackTrace? stackTrace]) =>
      _log(message, level: 1000, error: error, stackTrace: stackTrace);

  void _log(String message, {required int level, Object? error, StackTrace? stackTrace}) {
    if (kReleaseMode && level < 900) return;
    developer.log(message, name: name, level: level, error: error, stackTrace: stackTrace);
  }
}
