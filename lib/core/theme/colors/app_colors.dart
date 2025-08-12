import 'package:flutter/material.dart';

abstract class AppColors {
  // Brand colors
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryContainer = Color(0xFFEADDFF);
  static const Color secondary = Color(0xFF6366F1);
  static const Color secondaryContainer = Color(0xFFE8DEF8);
  static const Color tertiary = Color(0xFF6366F1);
  static const Color tertiaryContainer = Color(0xFFFFD8E4);

  // Surface colors
  static const Color surface = Color(0xFFFFFBFE);
  static const Color surfaceVariant = Color(0xFFE7E0EC);
  static const Color surfaceContainer = Color(0xFFF3EDF7);
  static const Color surfaceContainerHigh = Color(0xFFECE6F0);
  static const Color surfaceContainerHighest = Color(0xFFE6E0E9);

  // Background
  static const Color background = Color(0xFFFFFBFE);

  // Text colorss
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF21005D);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF1D192B);
  static const Color onSurface = Color(0xFF1C1B1F);
  static const Color onSurfaceVariant = Color(0xFF49454F);
  static const Color onBackground = Color(0xFF1C1B1F);

  // State colors
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFF410002);

  // Outline
  static const Color outline = Color(0xFF6366F1);
  static const Color outlineVariant = Color.fromARGB(255, 165, 97, 233);

  // Additional semantic colors
  static const Color success = Color(0xFF146C2E);
  static const Color successContainer = Color(0xFFA6F2AA);
  static const Color warning = Color(0xFFB3261E);
  static const Color warningContainer = Color(0xFFF2B8B5);
}