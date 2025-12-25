import 'dart:async';

/// Abstract interface for analytics service to allow multiple implementations
/// (e.g., Firebase Analytics, AppsFlyer, or a custom backend)
abstract class AnalyticsService {
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
}
