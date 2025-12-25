// lib/core/router/route_observer.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:xpensemate/core/service/service_locator.dart';
import 'package:xpensemate/core/utils/app_logger.dart';

class AppRouteObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _logNavigation('PUSH', route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _logNavigation('POP', route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null && oldRoute != null) {
      _logNavigation('REPLACE', newRoute, oldRoute);
    }
  }

  void _logNavigation(
      String action, Route<dynamic> route, Route<dynamic>? previousRoute) {
    final routeName = route.settings.name;
    final prevRouteName = previousRoute?.settings.name;

    final message = '🧭 $action: ${routeName ?? 'undefined'} '
        '${prevRouteName != null ? 'from $prevRouteName' : ''}';
    debugPrint(message);
    AppLogger.breadcrumb(message);

    // Track screen view in analytics
    // If it's a POP, the current active screen becomes the previous one
    final screenToTrack = action == 'POP' ? prevRouteName : routeName;
    if (screenToTrack != null) {
      unawaited(sl.analytics.setCurrentScreen(screenName: screenToTrack));
    }
  }
}
