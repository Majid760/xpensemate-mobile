// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:xpensemate/core/route/auth_routes.dart';
import 'package:xpensemate/core/route/home_routes.dart';
import 'package:xpensemate/core/route/profile_routes.dart';
import 'package:xpensemate/core/route/splash_page.dart';
import 'package:xpensemate/core/route/utils/error_page.dart';
import 'package:xpensemate/core/route/utils/main_shell.dart';
import 'package:xpensemate/core/route/utils/route_constants.dart';
import 'package:xpensemate/core/route/utils/router_middleware_guard.dart';
import 'package:xpensemate/core/service/analytics_service.dart';
import 'package:xpensemate/core/service/service_locator.dart';
import 'package:xpensemate/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:xpensemate/features/budget/presentation/widgets/budget_goal_list.dart';
import 'package:xpensemate/features/expense/presentation/pages/expense_page.dart';
import 'package:xpensemate/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:xpensemate/features/payment/presentation/pages/payment_page.dart';
import 'package:xpensemate/features/payment/presentation/pages/subscription_page.dart';

class AppRouter {
  AppRouter(this._authCubit, this._routeGuards, this._analyticsService);
  final AuthCubit _authCubit;
  final RouteGuards _routeGuards;
  final AnalyticsService _analyticsService;

  late final GoRouter router = GoRouter(
    observers: [
      _analyticsService.observer,
    ],
    // debugLogDiagnostics: true,
    initialLocation: RouteConstants.home,
    refreshListenable: _authCubit,
    redirect: _routeGuards.globalRedirectAsync,
    errorBuilder: (context, state) => ErrorPage(error: state.error),
    routes: [
      // Splash Routess
      GoRoute(
        path: RouteConstants.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashPage(),
      ),

      GoRoute(
        path: RouteConstants.onboarding,
        name: RouteNames.onboarding,
        builder: (context, state) => BlocProvider(
          create: (context) => sl.onboardingCubit,
          child: const OnboardingPage(),
        ),
      ),

      GoRoute(
        path: RouteConstants.subscription,
        name: RouteNames.subscription,
        builder: (context, state) => const SubscriptionPage(),
      ),

      // Auth Routes
      ...AuthRoutes.routes,

      // Main App Shell with Bottom Navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(
          child: child,
          customFabAction: (index) {
            if (index == 1) {
              addExpense(context: context);
            } else if (index == 3) {
              addBudget(context: context);
            } else if (index == 4) {
              addPayment(context: context);
            }
            return;
          },
        ),
        routes: [
          ...HomeRoutes.routes,
          ...ProfileRoutes.routes,
        ],
      ),
    ],
  );

  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');
  static final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'shell');

  static GlobalKey<NavigatorState> get rootNavigatorKey => _rootNavigatorKey;
  static GlobalKey<NavigatorState> get shellNavigatorKey => _shellNavigatorKey;
}
