// lib/core/router/route_guards.dart
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:xpensemate/core/route/utils/route_constants.dart';
import 'package:xpensemate/core/service/storage_service.dart';
import 'package:xpensemate/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:xpensemate/features/auth/presentation/cubit/auth_state.dart';

class RouteGuards {
  RouteGuards(this._authCubit, this._storageService);
  final AuthCubit _authCubit;
  final StorageService _storageService;

  Future<String?> globalRedirectAsync(
    BuildContext context,
    GoRouterState state,
  ) async {
    final isLoggedIn = _authCubit.state is AuthAuthenticated;
    final isLoginRoute = _isAuthRoute(state.matchedLocation);
    final isSplashRoute = state.matchedLocation == RouteConstants.splash;

    // Onboarding check
    final isOnboardingDone =
        await _storageService.get<bool>(key: 'onboarding_completed') ?? false;
    final isOnboardingRoute =
        state.matchedLocation == RouteConstants.onboarding;

    if (!isOnboardingDone && !isOnboardingRoute && !isSplashRoute) {
      return RouteConstants.onboarding;
    }

    if (isOnboardingDone && isOnboardingRoute) {
      return RouteConstants
          .login; // Or RouteConstants.subscription if we want to force valid flow
    }

    if (isSplashRoute) {
      return null;
    }

    if (!isLoggedIn && !isLoginRoute && !isOnboardingRoute) {
      // Allow subscription page? Maybe.
      if (state.matchedLocation == RouteConstants.subscription) return null;
      return RouteConstants.login;
    }

    if (isLoggedIn && isLoginRoute) {
      return RouteConstants.home;
    }

    return null;
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
    if (!authCubit.isAuthenticated) {
      return RouteConstants.login;
    }
    return null;
  }

  static String? requireGuest(BuildContext context, GoRouterState state) {
    final authCubit = context.authCubit;
    if (authCubit.isAuthenticated) {
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
  String? analyticsMiddleware(BuildContext context, GoRouterState state) =>
      null;

  /// Performance monitoring middleware
  String? performanceMiddleware(BuildContext context, GoRouterState state) =>
      null;

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
