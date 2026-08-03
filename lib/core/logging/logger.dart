import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warning, error }

class AppLogger {
  static bool _enabled = kDebugMode;

  static void enable({bool enabled = true}) => _enabled = enabled;

  static void _log(LogLevel level, String tag, String message, [Object? error]) {
    if (!_enabled) return;
    final timestamp = DateTime.now().toIso8601String().substring(11, 23);
    final prefix = switch (level) {
      LogLevel.debug   => '🔵 D',
      LogLevel.info    => '🟢 I',
      LogLevel.warning => '🟡 W',
      LogLevel.error   => '🔴 E',
    };
    debugPrint('[$timestamp] $prefix [$tag] $message');
    if (error != null) {
      debugPrint('         Error: $error');
    }
  }

  static void d(String tag, String message) => _log(LogLevel.debug, tag, message);
  static void i(String tag, String message) => _log(LogLevel.info, tag, message);
  static void w(String tag, String message) => _log(LogLevel.warning, tag, message);
  static void e(String tag, String message, [Object? error]) => _log(LogLevel.error, tag, message, error);
}
