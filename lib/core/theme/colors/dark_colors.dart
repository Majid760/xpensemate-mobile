import 'package:flutter/material.dart';

class DarkColors {
  static ColorScheme get colorScheme => const ColorScheme.dark(
        primary: AppDarkColors.primary,
        primaryContainer: AppDarkColors.primaryContainer,
        onPrimaryContainer: AppDarkColors.onPrimaryContainer,
        onPrimary: AppDarkColors.onPrimary,
        onTertiaryContainer: AppDarkColors.onTertiaryContainer,
        secondaryContainer: AppDarkColors.secondaryContainer,
        onSecondaryContainer: AppDarkColors.onSecondaryContainer,
        tertiary: AppDarkColors.tertiary,
        onTertiary: AppDarkColors.warningContainer,
        tertiaryContainer: AppDarkColors.tertiaryContainer,
        errorContainer: AppDarkColors.errorContainer,
        onErrorContainer: AppDarkColors.onErrorContainer,
        onSurface: AppDarkColors.onSurface,
        onSurfaceVariant: AppDarkColors.onSurfaceVariant,
        outline: AppDarkColors.outline,
        outlineVariant: AppDarkColors.outlineVariant,
        surfaceContainerHighest: AppDarkColors.surfaceContainerHighest,
      );
}

abstract class AppDarkColors {
  // Brand colors
  static const Color primary = Color(0xFFBB86FC);
  static const Color primaryContainer = Color(0xFF3700B3);
  static const Color secondary = Color(0xFF03DAC6);
  static const Color secondaryContainer = Color(0xFF005047);
  static const Color tertiary = Color(0xFFCF6679);
  static const Color tertiaryContainer = Color(0xFF633B48);

  // Surface colors
  static const Color surface = Color(0xFF1E1E1E);
  static const Color surfaceVariant = Color(0xFF49454F);
  static const Color surfaceContainer = Color(0xFF2C2C2C);
  static const Color surfaceContainerHigh = Color(0xFF373737);
  static const Color surfaceContainerHighest = Color(0xFF424242);

  // Background
  static const Color background = Color(0xFF121212);

  // Text colors
  static const Color onPrimary = Color.fromARGB(255, 0, 0, 0);
  static const Color onPrimaryContainer = Color(0xFFEFDDFF);
  static const Color onSecondary = Color(0xFF000000);
  static const Color onSecondaryContainer = Color(0xFF9FF2E5);
  static const Color onTertiary = Color(0xFF000000);
  static const Color onTertiaryContainer = Color(0xFF633B48);
  static const Color onSurface = Color(0xFFE6E1E5);
  static const Color onSurfaceVariant = Color(0xFFCAC4D0);
  static const Color onBackground = Color(0xFFE6E1E5);

  // State colors
  static const Color error = Color(0xFFCF6679);
  static const Color errorContainer = Color(0xFF93000A);
  static const Color onError = Color(0xFF000000);
  static const Color onErrorContainer = Color(0xFFFFDAD6);

  // Outline
  static const Color outline = Color.fromARGB(255, 179, 140, 238);
  static const Color outlineVariant = Color(0xFF49454F);

  // Additional semantic colors
  static const Color success = Color(0xFF6EE7B7);
  static const Color successContainer = Color(0xFF065F46);
  static const Color warning = Color(0xFFFCD34D);
  static const Color warningContainer = Color(0xFF92400E);
  static const Color info = Color(0xFF93C5FD);
  static const Color infoContainer = Color(0xFF1E3A8A);
  static const Color danger = Color(0xFFFCA5A5);
  static const Color dangerContainer = Color(0xFF7F1D1D);
}
