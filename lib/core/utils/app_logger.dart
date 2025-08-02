// lib/core/logging/app_logger.dart
import 'package:logger/logger.dart';

class AppLogger {
  static Logger? _logger;
  
  // Initialize logger (call once in main())
  static void init({required bool isDebug}) {
    _logger = Logger(
      printer: PrettyPrinter(
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
      level: isDebug ? Level.debug : Level.info,
    );
  }

   static void log(String message, [dynamic error]) {
    _logger?.d(message, error: error);
  }
  // Simple logging methods
  static void d(String message, [dynamic error]) {
    _logger?.d(message, error: error);
  }

  static void i(String message, [dynamic error]) {
    _logger?.i(message, error: error);
  }

  static void w(String message, [dynamic error]) {
    _logger?.w(message, error: error);
  }

  static void e(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger?.e(message, error: error, stackTrace: stackTrace);
  }

  // Tagged logging
  static void tag(String tag, String message, {LogLevel level = LogLevel.info}) {
    final taggedMessage = '[$tag] $message';
    switch (level) {
      case LogLevel.debug:
        d(taggedMessage);
        break;
      case LogLevel.info:
        i(taggedMessage);
        break;
      case LogLevel.warning:
        w(taggedMessage);
        break;
      case LogLevel.error:
        e(taggedMessage);
        break;
    }
  }

  // Network logging
  static void network(String method, String url, {int? statusCode, dynamic error}) {
    final message = '$method $url ${statusCode != null ? '($statusCode)' : ''}';
    if (error != null || (statusCode != null && statusCode >= 400)) {
      e(message, error);
    } else {
      i(message);
    }
  }

  // User action logging
  static void userAction(String action, [Map<String, dynamic>? params]) {
    final message = 'User: $action${params != null ? ' $params' : ''}';
    i(message);
  }
}

enum LogLevel { debug, info, warning, error }

// Extension for easy logging on any class
extension LogExt on Object {
  void logD(String message) => AppLogger.tag(runtimeType.toString(), message, level: LogLevel.debug);
  void logI(String message) => AppLogger.tag(runtimeType.toString(), message);
  void logW(String message) => AppLogger.tag(runtimeType.toString(), message, level: LogLevel.warning);
  void logE(String message, [dynamic error]) => AppLogger.tag(runtimeType.toString(), message, level: LogLevel.error);
}


// extension for logger class
extension LoggerExt on Logger {
  void logD(String message) => AppLogger.tag(runtimeType.toString(), message, level: LogLevel.debug);
  void logI(String message) => AppLogger.tag(runtimeType.toString(), message);
  void logW(String message) => AppLogger.tag(runtimeType.toString(), message, level: LogLevel.warning);
  void logE(String message, [dynamic error]) => AppLogger.tag(runtimeType.toString(), message, level: LogLevel.error);
}
