import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Abstract class defining the contract for crash reporting services.
abstract class CrashlyticsService {
  /// Initializes the crash reporting service.
  Future<void> init();

  /// Logs a non-fatal error.
  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    dynamic reason,
  });

  /// Logs a custom message to the crash report logs.
  Future<void> log(String message);

  /// Sets a custom key-value pair for subsequent crash reports.
  Future<void> setCustomKey(String key, Object value);

  /// Sets the user identifier for crash reports.
  Future<void> setUserIdentifier(String identifier);

  /// Pass the unhandled errors to the crash reporting service.
  /// Used for [FlutterError.onError].
  Future<void> recordFlutterError(FlutterErrorDetails details);

  /// Returns true if crash collection is enabled.
  bool get isCrashlyticsCollectionEnabled;
}

/// Concrete implementation of [CrashlyticsService] using Firebase Crashlytics.
class FirebaseCrashlyticsService implements CrashlyticsService {
  FirebaseCrashlyticsService({
    FirebaseCrashlytics? crashlytics,
    Logger? logger,
  })  : _crashlytics = crashlytics ?? FirebaseCrashlytics.instance,
        _logger = logger ?? Logger();

  final FirebaseCrashlytics _crashlytics;
  final Logger _logger;

  @override
  Future<void> init() async {
    // Pass all uncaught "fatal" errors from the framework to Crashlytics
    FlutterError.onError = _crashlytics.recordFlutterError;

    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      _crashlytics.recordError(error, stack, fatal: true);
      return true;
    };

    if (kDebugMode) {
      // Force disable Crashlytics collection while doing every day development.
      // Temporarily toggle this to true if you want to test crash reporting in your app.
      await _crashlytics.setCrashlyticsCollectionEnabled(false);
    } else {
      // Handle Crashlytics enabled status when not in debug,
      // e.g. allow your users to opt-in to crash reporting.
      await _crashlytics.setCrashlyticsCollectionEnabled(true);
    }

    _logger.i('FirebaseCrashlyticsService initialized');
  }

  @override
  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    dynamic reason,
  }) async {
    try {
      if (kDebugMode) {
        _logger.e(
          'Error caught (Debug Mode): $exception',
          error: exception,
          stackTrace: stack,
        );
        return;
      }
      await _crashlytics.recordError(exception, stack, reason: reason);
    } on Exception catch (e, s) {
      _logger.e(
        'Failed to record error to Crashlytics',
        error: e,
        stackTrace: s,
      );
    }
  }

  @override
  Future<void> log(String message) async {
    try {
      if (kDebugMode) {
        _logger.d('Crashlytics Log: $message');
        // We generally don't send simple logs to Crashlytics in debug, but we can if testing.
      }
      await _crashlytics.log(message);
    } on Exception catch (e) {
      _logger.e('Failed to log message to Crashlytics', error: e);
    }
  }

  @override
  Future<void> setCustomKey(String key, Object value) async {
    try {
      await _crashlytics.setCustomKey(key, value);
    } on Exception catch (e) {
      _logger.e('Failed to set custom key in Crashlytics', error: e);
    }
  }

  @override
  Future<void> setUserIdentifier(String identifier) async {
    try {
      await _crashlytics.setUserIdentifier(identifier);
    } on Exception catch (e) {
      _logger.e('Failed to set user identifier in Crashlytics', error: e);
    }
  }

  @override
  Future<void> recordFlutterError(FlutterErrorDetails details) async {
    try {
      await _crashlytics.recordFlutterError(details);
    } on Exception catch (e) {
      _logger.e('Failed to record Flutter error to Crashlytics', error: e);
    }
  }

  @override
  bool get isCrashlyticsCollectionEnabled =>
      _crashlytics.isCrashlyticsCollectionEnabled;
}
