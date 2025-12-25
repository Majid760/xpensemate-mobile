import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Abstract interface for analytics service to allow multiple implementations
/// (e.g., Firebase Analytics, AppsFlyer, or a custom backend)
sealed class AnalyticsService {
  /// Initialize the service
  Future<void> init();

  /// Log a custom event with optional parameters
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  });

  /// Track screen view
  Future<void> setCurrentScreen({
    required String screenName,
    String? screenClassOverride,
  });

  /// Set user ID for cross-platform tracking
  Future<void> setUserId(String? id);

  /// Set custom user property
  Future<void> setUserProperty({
    required String name,
    required String? value,
  });

  /// Reset all user data (useful for logout)
  Future<void> resetAnalyticsData();

  /// Enable or disable collection
  Future<void> setAnalyticsCollectionEnabled(bool enabled);

  /// Get navigator observer
  NavigatorObserver get observer;
}

/// Implementation of [AnalyticsService] using Firebase Analytics
class FirebaseAnalyticsService implements AnalyticsService {
  FirebaseAnalyticsService._();
  static final FirebaseAnalyticsService instance = FirebaseAnalyticsService._();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final _debugMode = !kDebugMode;

  @override
  Future<void> init() async {
    // Disable collection in debug mode
    if (_debugMode) {
      await _analytics.setAnalyticsCollectionEnabled(false);
    } else {
      await _analytics.setAnalyticsCollectionEnabled(true);
    }
  }

  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    if (_debugMode) return;
    await _analytics.logEvent(
      name: name,
      parameters: parameters,
    );
  }

  @override
  Future<void> setCurrentScreen({
    required String screenName,
    String? screenClassOverride,
  }) async {
    if (_debugMode) return;
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClassOverride,
    );
  }

  @override
  Future<void> setUserId(String? id) async {
    if (_debugMode) return;
    await _analytics.setUserId(id: id);
  }

  @override
  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    if (_debugMode) return;
    await _analytics.setUserProperty(name: name, value: value);
  }

  @override
  Future<void> resetAnalyticsData() async {
    await _analytics.resetAnalyticsData();
  }

  @override
  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    await _analytics.setAnalyticsCollectionEnabled(enabled);
  }

  /// Get navigator observer for Firebase Analytics
  @override
  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);
}
