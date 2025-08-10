// lib/core/router/routes/home_routes.dart
import 'package:go_router/go_router.dart';
import 'package:xpensemate/core/route/utils/main_shell.dart';
import 'package:xpensemate/core/route/utils/route_constants.dart';
import 'package:xpensemate/core/route/utils/router_middleware_guard.dart';
import 'package:xpensemate/features/auth/presentation/pages/email_verify_page.dart';
import 'package:xpensemate/features/home/presentation/pages/home_page.dart';
import 'package:xpensemate/features/notification/presentation/pages/notification_page.dart';
import 'package:xpensemate/features/profile/presentation/pages/profile_page.dart';

abstract class HomeRoutes {
  static List<RouteBase> get routes => [
    GoRoute(
      path: RouteConstants.home,
      name: RouteNames.home,
      redirect: RouteGuards.requireAuth,
      builder: (context, state) =>  const ProfilePage(),
      routes: [
        // GoRoute(
        //   path: 'dashboard',
        //   name: RouteNames.dashboard,
        //   builder: (context, state) => const DashboardPage(),
        // ),R
        // GoRoute(
        //   path: 'dashboard',
        //   name: RouteNames.profile,
        //   builder: (context, state) => const ProfilePage(),
        // ),
        GoRoute(
          path: 'notifications',
          name: RouteNames.notifications,
          builder: (context, state) => const NotificationPage(),
        ),
      ],
    ),
  ];
}
