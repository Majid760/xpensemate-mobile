// lib/features/splash/presentation/pages/splash_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // Simulate initialization process
    await Future<void>.delayed(const Duration(seconds: 2));
    
    // Check authentication status and navigate accordingly
    // This would typically check with your AuthService
    if (mounted) {
      context.go('/home'); // or '/login' based on auth status
    }
  }

  @override
  Widget build(BuildContext context) => const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FlutterLogo(size: 100),
            SizedBox(height: 24),
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading...'),
          ],
        ),
      ),
    );
}