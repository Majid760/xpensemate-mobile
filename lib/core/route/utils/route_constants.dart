// lib/core/router/route_constants.dart
abstract class RouteConstants {
  // Auth Routes
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String emailVerify = '/email-verify';

  // Home Routes
  static const String home = '/home';
  static const String dashboard = '/home/dashboard';
  static const String budget = '/home/budget';
  static const String expense = '/home/expense';
  static const String payment = '/home/payment';
  static const String notifications = '/home/notifications';

  // Profile Routes
  static const String profile = '/profile';
  static const String settings = '/profile/settings';
  static const String editProfile = '/profile/edit';

  // Onboarding & Subscription
  static const String onboarding = '/onboarding';
  static const String subscription = '/subscription';

  // Error Routes
  static const String notFound = '/404';
}

abstract class RouteNames {
  // Auth Routes
  static const String splash = 'splash';
  static const String login = 'login';
  static const String register = 'register';
  static const String forgotPassword = 'forgot-password';
  static const String emailVerify = 'email-verify';

  // Home Routes
  static const String home = 'home';
  static const String dashboard = 'dashboard';
  static const String budget = 'budget';
  static const String expense = 'expense';
  static const String payment = 'payment';
  static const String notifications = 'notifications';

  // Profile Routes
  static const String profile = 'profile';
  static const String settings = 'settings';
  static const String editProfile = 'edit-profile';

  // Onboarding & Subscription
  static const String onboarding = 'onboarding';
  static const String subscription = 'subscription';
}
