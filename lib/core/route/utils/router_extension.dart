// lib/core/router/router_extensions.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:xpensemate/core/utils/app_logger.dart';

extension GoRouterExtension on BuildContext {
  // Navigation methods
  void goToLogin() => go('/login');
  void goToHome() => go('/home');
  void goToProfile() => go('/profile');
  
  // Push methods
  void pushLogin() => push('/login');
  void pushProfile() => push('/profile');
  
  // Replace methods
  void replaceWithHome() => pushReplacement('/home');
  void replaceWithLogin() => pushReplacement('/login');
  
  // Pop methods
  void popToRoot() => go('/');
  
  // Generic navigation with error handling
  Future<T?> navigateTo<T extends Object?>(
    String path, {
    Object? extra,
    Map<String, String> pathParameters = const {},
    Map<String, dynamic> queryParameters = const {},
  }) async {
    try {
      return await push<T>(
        path,
        extra: extra,
      );
    } on Exception catch (e) {
      AppLogger.e('Navigation err or: $e');
      return null;
    }
  }
}
