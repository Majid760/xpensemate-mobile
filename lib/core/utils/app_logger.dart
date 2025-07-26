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

// ============ USAGE ============

/*
// 1. Add to pubspec.yaml:
dependencies:
  logger: ^2.0.2+1

// 2. Initialize in main.dart:
void main() {
  AppLogger.init(isDebug: kDebugMode);
  runApp(MyApp());
}

// 3. Use anywhere:
AppLogger.d('Debug message');
AppLogger.i('Info message');
AppLogger.w('Warning message');
AppLogger.e('Error message', error);

// Tagged logging:
AppLogger.tag('AUTH', 'User logged in');
AppLogger.tag('API', 'Request failed', level: LogLevel.error);

// Network logging:
AppLogger.network('GET', '/api/users', statusCode: 200);
AppLogger.network('POST', '/api/login', statusCode: 401, error: 'Unauthorized');

// User actions:
AppLogger.userAction('button_tap', {'screen': 'login', 'button': 'submit'});

// Class-based logging:
class UserService {
  void login() {
    logI('Login attempt started');  // Auto-tagged as [UserService]
    try {
      // login logic
      logI('Login successful');
    } catch (e) {
      logE('Login failed', e);
    }
  }
}
*/