
// lib/core/router/router_delegate.dart
import 'package:go_router/go_router.dart';

class RouterDelegate {
  
  RouterDelegate(this._router);
  final GoRouter _router;

  // Centralized navigation methods
  void navigateToLogin() => _router.go('/login');
  void navigateToHome() => _router.go('/home');
  void navigateToProfile() => _router.go('/profile');
  
  Future<void> navigateWithAnimation(
    String path, {
    Duration duration = const Duration(milliseconds: 300),
  }) async {
    // Custom animation logic can be added here
    _router.go(path);
  }
  
  void clearAndNavigateTo(String path) {
    // Clear navigation stack and navigate
    _router.go(path);
  }
  
  bool canPop() => _router.canPop();
  
  void pop<T extends Object?>([T? result]) {
    if (_router.canPop()) {
      _router.pop(result);
    }
  }
}