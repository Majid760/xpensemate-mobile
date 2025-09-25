// lib/core/router/routes/home_routes.dart
import 'package:go_router/go_router.dart';
import 'package:xpensemate/core/route/utils/main_shell.dart';
import 'package:xpensemate/core/route/utils/route_constants.dart';
import 'package:xpensemate/core/route/utils/router_middleware_guard.dart';
import 'package:xpensemate/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:xpensemate/features/expense/presentation/pages/expense_page.dart';
import 'package:xpensemate/features/home/presentation/pages/home_page.dart';

abstract class HomeRoutes {
  static List<RouteBase> get routes => [
        GoRoute(
          path: RouteConstants.home,
          name: RouteNames.home,
          redirect: RouteGuards.requireAuth,
          builder: (context, state) => const DashboardPage(),
          routes: [
            GoRoute(
              path: 'dashboard',
              name: RouteNames.dashboard,
              builder: (context, state) => const DashboardPage(),
            ),
            GoRoute(
              path: 'expense',
              name: 'expense',
              builder: (context, state) => const ExpensePage(), // Placeholder
            ),
            GoRoute(
              path: 'budget',
              name: 'budget',
              builder: (context, state) => const HomePage(), // Placeholder
            ),
            GoRoute(
              path: 'payment',
              name: 'payment',
              builder: (context, state) => const HomePage(), // Placeholder
            ),
            GoRoute(
              path: 'notifications',
              name: RouteNames.notifications,
              builder: (context, state) => const HomePage(),
            ),
          ],
        ),
      ];
}
