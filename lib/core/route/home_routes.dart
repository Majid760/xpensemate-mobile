// lib/core/router/routes/home_routes.dart
import 'package:go_router/go_router.dart';
import 'package:xpensemate/core/route/utils/route_constants.dart';
import 'package:xpensemate/core/route/utils/router_middleware_guard.dart';
import 'package:xpensemate/features/budget/presentation/pages/budget_page.dart';
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
              name: RouteNames.expense,
              builder: (context, state) => const ExpensePage(),
            ),
            GoRoute(
              path: 'budget',
              name: RouteNames.budget,
              builder: (context, state) => const BudgetPage(),
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
