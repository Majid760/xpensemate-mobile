// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:xpensemate/core/route/auth_routes.dart';
import 'package:xpensemate/core/route/home_routes.dart';
import 'package:xpensemate/core/route/profile_routes.dart';
import 'package:xpensemate/core/route/splash_page.dart';
import 'package:xpensemate/core/route/utils/error_page.dart';
import 'package:xpensemate/core/route/utils/main_shell.dart';
import 'package:xpensemate/core/route/utils/route_constants.dart';
import 'package:xpensemate/core/route/utils/router_middleware_guard.dart';
import 'package:xpensemate/core/widget/app_snackbar.dart';
import 'package:xpensemate/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:xpensemate/features/expense/presentation/pages/expense_page.dart';
import 'package:xpensemate/features/expense/presentation/widgets/expense_form_widget.dart';
import 'package:xpensemate/core/widget/app_bottom_sheet.dart';

class AppRouter {
  AppRouter(this._authCubit, this._routeGuards);
  final AuthCubit _authCubit;
  final RouteGuards _routeGuards;

  late final GoRouter router = GoRouter(
    debugLogDiagnostics: true,
    initialLocation: RouteConstants.splash,
    refreshListenable: _authCubit,
    redirect: _routeGuards.globalRedirect,
    errorBuilder: (context, state) => ErrorPage(error: state.error),
    routes: [
      // Splash Routess
      GoRoute(
        path: RouteConstants.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashPage(),
      ),

      // Auth Routes
      ...AuthRoutes.routes,

      // Main App Shell with Bottom Navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          // Check if we're on the expense page and provide custom FAB action
          if (state.matchedLocation == '/home/budget') {
            return MainShell(
              child: child,
              customFabAction: () {
                addExpense(context);
              },
            );
          }
          // For other pages, use default behavior
          return MainShell(child: child);
        },
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
