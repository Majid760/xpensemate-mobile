
// lib/core/router/route_guards.dart
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'package:xpensemate/core/route/utils/route_constants.dart';
import 'package:xpensemate/features/auth/presentation/cubit/auth_cubit.dart';

class RouteGuards {
  
  RouteGuards(this._authCubit);
  final AuthCubit _authCubit;

  String? globalRedirect(BuildContext context, GoRouterState state) {
    final isLoggedIn = _authCubit.state.isAuthenticated;
    final isLoginRoute = _isAuthRoute(state.matchedLocation);
    final isSplashRoute = state.matchedLocation == RouteConstants.splash;

    // Handle splash screen logic
    if (isSplashRoute) {
      return null; // Let splash screen handle the redirect
    }

    // Redirect to login if not authenticated and trying to access protected routes
    if (!isLoggedIn && !isLoginRoute) {
      return RouteConstants.login;
    }

    // Redirect to home if authenticated and trying to access auth routes
    if (isLoggedIn && isLoginRoute) {
      return RouteConstants.home;
    }

    return null; // No redirect needed
  }

  bool _isAuthRoute(String location) {
    const authRoutes = [
      RouteConstants.login,
      RouteConstants.register,
      RouteConstants.forgotPassword,
      RouteConstants.emailVerify,
    ];
    return authRoutes.contains(location);
  }

  static String? requireAuth(BuildContext context, GoRouterState state) {
    final authCubit = context.authCubit;
    if (!authCubit.state.isAuthenticated) {
      return RouteConstants.login;
    }
    return null;
  }

  static String? requireGuest(BuildContext context, GoRouterState state) {
    final authCubit = context.authCubit;
    if (authCubit.state.isAuthenticated) {
      return RouteConstants.home;
    }
    return null;
  }
}

/// Route middleware
class RouteMiddleware {
  /// Log route changes
  String? loggingMiddleware(BuildContext context, GoRouterState state) {
    debugPrint('🧭 Navigating to: ${state.matchedLocation}');
    debugPrint('🧭 Full location: ${state.fullPath}');
    return null; // Continue navigation
  }

  /// Analytics middleware
  String? analyticsMiddleware(BuildContext context, GoRouterState state) => null;

  /// Performance monitoring middleware
  String? performanceMiddleware(BuildContext context, GoRouterState state) => null;

  /// Combine multiple middlewares
  String? combineMiddlewares(
    BuildContext context,
    GoRouterState state,
    List<String? Function(BuildContext, GoRouterState)> middlewares,
  ) {
    for (final middleware in middlewares) {
      final result = middleware(context, state);
      if (result != null) {
        return result; // Stop execution and redirect
      }
    }
    return null; // Continue navigation
  }
}