// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:xpensemate/core/route/auth_routes.dart';
import 'package:xpensemate/core/route/profile_routes.dart';
import 'package:xpensemate/core/route/splash_page.dart';
import 'package:xpensemate/core/route/utils/error_page.dart';
import 'package:xpensemate/core/route/utils/main_shell.dart';
import 'package:xpensemate/core/route/utils/route_constants.dart';
import 'package:xpensemate/core/route/utils/router_middleware_guard.dart';
import 'package:xpensemate/core/service/analytics_service.dart';
import 'package:xpensemate/core/service/service_locator.dart';
import 'package:xpensemate/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:xpensemate/features/budget/presentation/pages/budget_page.dart';
import 'package:xpensemate/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:xpensemate/features/expense/presentation/pages/expense_page.dart';
import 'package:xpensemate/features/home/presentation/pages/home_page.dart';
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
    initialLocation: RouteConstants.splash,
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

      // Profile Routes
      ...ProfileRoutes.routes,

      // Main App Shell with Bottom Navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => MainShell(
          navigationShell: navigationShell,
          customFabAction: (index) {
            if (index == 1) {
              addExpense(context: context);
            } else if (index == 3) {
              addBudget(context: context);
            } else if (index == 4) {
              addPayment(context: context);
            }
          },
        ),
        branches: [
          // Branch 0: Dashboard (Home)
          StatefulShellBranch(
            navigatorKey: _rootNavigatorKey,
            routes: [
              GoRoute(
                path: RouteConstants.home,
                name: RouteNames.home,
                redirect: RouteGuards.requireAuth,
                builder: (context, state) => const DashboardPageWrapper(),
                routes: [
                  GoRoute(
                    path: 'dashboard',
                    name: RouteNames.dashboard,
                    builder: (context, state) => const DashboardPageWrapper(),
                  ),
                  GoRoute(
                    path: 'notifications',
                    name: RouteNames.notifications,
                    builder: (context, state) => const HomePage(),
                  ),
                ],
              ),
            ],
          ),

          // Branch 1: Expense
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/expense',
                name: RouteNames.expense,
                builder: (context, state) => const ExpensePage(),
              ),
            ],
          ),

          // Branch 2: Budget
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/budget',
                name: RouteNames.budget,
                builder: (context, state) => const BudgetPage(),
              ),
            ],
          ),

          // Branch 3: Payment
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/payment',
                name: RouteNames.payment,
                builder: (context, state) => const PaymentPage(),
              ),
            ],
          ),
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
