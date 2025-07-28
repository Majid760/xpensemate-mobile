// lib/core/router/routes/auth_routes.dart
import 'package:go_router/go_router.dart';
import 'package:xpensemate/core/route/utils/route_constants.dart';
import 'package:xpensemate/core/route/utils/router_middleware_guard.dart';
import 'package:xpensemate/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:xpensemate/features/auth/presentation/pages/login_page.dart';
import 'package:xpensemate/features/auth/presentation/pages/register_page.dart';

abstract class AuthRoutes {
  static List<RouteBase> get routes => [
    GoRoute(
      path: RouteConstants.login,
      name: RouteNames.login,
      redirect: RouteGuards.requireGuest,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: RouteConstants.register,
      name: RouteNames.register,
      redirect: RouteGuards.requireGuest,
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: RouteConstants.forgotPassword,
      name: RouteNames.forgotPassword,
      redirect: RouteGuards.requireGuest,
      builder: (context, state) => const ForgotPasswordPage(),
    ),
  ];
}
