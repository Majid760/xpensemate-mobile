// lib/core/router/routes/profile_routes.dart
import 'package:go_router/go_router.dart';
import 'package:xpensemate/core/route/utils/route_constants.dart';
import 'package:xpensemate/core/route/utils/router_middleware_guard.dart';
import 'package:xpensemate/features/profile/presentation/pages/profile_page.dart';
import 'package:xpensemate/features/profile/presentation/pages/setting_page.dart';

abstract class ProfileRoutes {
  static List<RouteBase> get routes => [
        GoRoute(
          path: RouteConstants.profile,
          name: RouteNames.profile,
          redirect: RouteGuards.requireAuth,
          builder: (context, state) => ProfilePage(),
          routes: [
            GoRoute(
              path: 'settings',
              name: RouteNames.settings,
              builder: (context, state) => const SettingsPage(),
            ),
            GoRoute(
              path: 'edit',
              name: RouteNames.editProfile,
              builder: (context, state) => ProfilePage(),
            ),
          ],
        ),
      ];
}
