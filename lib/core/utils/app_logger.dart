import 'dart:async';

import 'package:logger/logger.dart';
import 'package:xpensemate/core/service/service_locator.dart';

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
    // Automatically report to Crashlytics
    unawaited(
      sl.crashlytics.recordError(
        error ?? message,
        stackTrace,
        reason: message,
      ),
    );
  }

  // Tagged logging
  static void tag(
    String tag,
    String message, {
    LogLevel level = LogLevel.info,
  }) {
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
  static void network(
    String method,
    String url, {
    int? statusCode,
    dynamic error,
  }) {
    final message = '$method $url ${statusCode != null ? '($statusCode)' : ''}';
    if (error != null || (statusCode != null && statusCode >= 400)) {
      e(message, error);
    } else {
      i(message);
    }

    // Log to Analytics
    unawaited(
      sl.analytics.logEvent(
        name: 'network_request',
        parameters: {
          'method': method,
          'url': url,
          if (statusCode != null) 'status_code': statusCode,
          if (error != null) 'error': error.toString(),
        },
      ),
    );
  }

  // Analytics logging
  static void analyticsEvent(String name, [Map<String, Object>? params]) {
    unawaited(sl.analytics.logEvent(name: name, parameters: params));
  }

  // User action logging
  static void userAction(String action, [Map<String, dynamic>? params]) {
    final message = 'User: $action${params != null ? ' $params' : ''}';
    i(message);
    breadcrumb(message);
    // Log to Firebase Analytics
    final eventName = action.replaceAll(' ', '_').toLowerCase();
    unawaited(
      sl.analytics.logEvent(
        name: eventName,
        parameters: params?.map((key, value) => MapEntry(key, value as Object)),
      ),
    );
  }

  // Crashlytics Breadcrumb
  static void breadcrumb(String message) {
    unawaited(sl.crashlytics.log(message));
  }

  // User Identifier
  static void setUserId(String identifier) {
    unawaited(sl.crashlytics.setUserIdentifier(identifier));
    unawaited(sl.analytics.setUserId(identifier));
  }

  // Crashlytics Custom Key
  static void setCustomKey(String key, Object value) {
    unawaited(sl.crashlytics.setCustomKey(key, value));
  }

  // Reset all analytics/crashlytics data
  static void reset() {
    breadcrumb('Resetting logger data...');
    setUserId('');
    unawaited(sl.analytics.resetAnalyticsData());
  }
}

enum LogLevel { debug, info, warning, error }

// Extension for easy logging on any class
extension LogExt on Object {
  void logD(String message) =>
      AppLogger.tag(runtimeType.toString(), message, level: LogLevel.debug);
  void logI(String message) => AppLogger.tag(runtimeType.toString(), message);
  void logW(String message) =>
      AppLogger.tag(runtimeType.toString(), message, level: LogLevel.warning);
  void logE(String message, [dynamic error, StackTrace? s]) =>
      AppLogger.e('[$runtimeType] $message', error, s);
}

// extension for logger class
extension LoggerExt on Logger {
  void logD(String message) =>
      AppLogger.tag(runtimeType.toString(), message, level: LogLevel.debug);
  void logI(String message) => AppLogger.tag(runtimeType.toString(), message);
  void logW(String message) =>
      AppLogger.tag(runtimeType.toString(), message, level: LogLevel.warning);
  void logE(String message, [dynamic error, StackTrace? s]) =>
      AppLogger.e('[$runtimeType] $message', error, s);
}
