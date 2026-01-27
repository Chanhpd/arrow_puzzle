import 'dart:developer';

import 'package:flutter/foundation.dart';

var logger = MyLogger();

class MyLogger {
  /// Log a message at level verbose.
  void v(dynamic message) {
    _log("🤍 VERBOSE: $message");
  }

  /// Log a message at level debug.
  void d(dynamic message) {
    _log("💙 DEBUG: $message");
  }

  /// Log a message at level info.
  void i(dynamic message) {
    _log("❤️ INFO: $message");
  }

  /// Log a message at level warning.
  void w(dynamic message) {
    _log("💛 WARNING: $message");
  }

  /// Log a message at level error.
  void e(dynamic message) {
    _log("❤️‍🔥 ERROR: $message");
  }

  // === API Feature Logging Methods ===

  /// Log API requests and responses
  void api(dynamic message) {
    _log("🌐 API: $message");
  }

  /// Log repository operations
  void repository(dynamic message) {
    _log("💾 REPO: $message");
  }

  /// Log use case operations
  void useCase(dynamic message) {
    _log("⚡ USE_CASE: $message");
  }

  /// Log Cubit/State changes
  void cubit(dynamic message) {
    _log("🎯 CUBIT: $message");
  }

  /// Log cache operations
  void cache(dynamic message) {
    _log("💽 CACHE: $message");
  }

  /// Log successful operations
  void success(dynamic message) {
    _log("✅ SUCCESS: $message");
  }

  /// Log user actions
  void userAction(dynamic message) {
    _log("👤 USER: $message");
  }

  /// Log navigation events
  void navigation(dynamic message) {
    _log("🧭 NAV: $message");
  }

  /// Log performance metrics
  void performance(String operation, Duration duration) {
    _log("⏱️ PERFORMANCE: $operation took ${duration.inMilliseconds}ms");
  }

  void _log(dynamic message) {
    if (kDebugMode) {
      print("$message");
    }
  }

  /// Log a long message
  void long(dynamic message) {
    log(message);
  }
}
