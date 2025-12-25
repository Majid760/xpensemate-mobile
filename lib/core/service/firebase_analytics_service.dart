import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:xpensemate/core/service/analytics_service.dart';

/// Implementation of [AnalyticsService] using Firebase Analytics
class FirebaseAnalyticsService implements AnalyticsService {
  FirebaseAnalyticsService._();
  static final FirebaseAnalyticsService instance = FirebaseAnalyticsService._();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  @override
  Future<void> init() async {
    // Basic configuration if needed
    await _analytics.setAnalyticsCollectionEnabled(true);
  }

  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
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
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClassOverride,
    );
  }

  @override
  Future<void> setUserId(String? id) async {
    await _analytics.setUserId(id: id);
  }

  @override
  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
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
  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);
}
