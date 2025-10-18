import 'package:flutter/foundation.dart';

/// Simple logger utility for debugging
class Logger {
  Logger._();

  /// Log debug message
  static void debug(String message, [dynamic data]) {
    if (kDebugMode) {
      print('🔵 DEBUG: $message');
      if (data != null) {
        print('   Data: $data');
      }
    }
  }

  /// Log info message
  static void info(String message, [dynamic data]) {
    if (kDebugMode) {
      print('ℹ️ INFO: $message');
      if (data != null) {
        print('   Data: $data');
      }
    }
  }

  /// Log warning message
  static void warning(String message, [dynamic data]) {
    if (kDebugMode) {
      print('⚠️ WARNING: $message');
      if (data != null) {
        print('   Data: $data');
      }
    }
  }

  /// Log error message
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('❌ ERROR: $message');
      if (error != null) {
        print('   Error: $error');
      }
      if (stackTrace != null) {
        print('   StackTrace: $stackTrace');
      }
    }
  }

  /// Log success message
  static void success(String message, [dynamic data]) {
    if (kDebugMode) {
      print('✅ SUCCESS: $message');
      if (data != null) {
        print('   Data: $data');
      }
    }
  }
}

