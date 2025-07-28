// lib/core/router/route_utils.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RouteUtils {
  // Prevent instantiation
  RouteUtils._();

  /// Check if current route matches the given path
  static bool isCurrentRoute(BuildContext context, String path) {
    final currentLocation = GoRouterState.of(context).matchedLocation;
    return currentLocation == path;
  }

  /// Extract route parameters safely
  static String? getPathParameter(GoRouterState state, String paramName) => state.pathParameters[paramName];

  /// Extract query parameters safely
  static String? getQueryParameter(GoRouterState state, String paramName) => state.uri.queryParameters[paramName];

  /// Build route with parameters
  static String buildRoute(String path, Map<String, String> params) {
    var result = path;
    params.forEach((key, value) {
      result = result.replaceAll(':$key', value);
    });
    return result;
  }

  /// Validate route parameters
  static bool validateRequiredParams(
    GoRouterState state,
    List<String> requiredParams,
  ) {
    for (final param in requiredParams) {
      if (state.pathParameters[param] == null) {
        return false;
      }
    }
    return true;
  }
}

/// Route Animations
class RouteAnimations {
  // Prevent instantiation
  RouteAnimations._();

  /// Slide transition from right
  static Page<T> slideFromRight<T extends Object?>(
    BuildContext context,
    GoRouterState state,
    Widget child,
  ) => CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1, 0);
        const end = Offset.zero;
        const curve = Curves.ease;

        final tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );

  /// Fade transition
  static Page<T> fadeTransition<T extends Object?>(
    BuildContext context,
    GoRouterState state,
    Widget child,
  ) => CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(
          opacity: animation,
          child: child,
        ),
    );

  /// Scale transition
  static Page<T> scaleTransition<T extends Object?>(
    BuildContext context,
    GoRouterState state,
    Widget child,
  ) => CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) => ScaleTransition(
          scale: animation,
          child: child,
        ),
    );
}
