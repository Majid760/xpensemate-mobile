// lib/core/router/route_observer.dart
import 'package:flutter/material.dart';
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
    final message = '🧭 $action: ${route.settings.name} '
        '${previousRoute != null ? 'from ${previousRoute.settings.name}' : ''}';
    debugPrint(message);
    AppLogger.breadcrumb(message);
  }
}
