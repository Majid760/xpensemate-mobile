import 'package:flutter/material.dart';
import 'package:xpensemate/core/theme/app_spacing.dart';
import 'package:xpensemate/core/theme/theme_constant.dart';


class AppButtonStyles {
  // Elevated Button
  static ButtonStyle get elevatedButton => ElevatedButton.styleFrom(
        elevation: ThemeConstants.elevationLow,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMedium),
        ),
        minimumSize: const Size(64, 48),
      );

  // Filled Button
  static ButtonStyle get filledButton => FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMedium),
        ),
        minimumSize: const Size(64, 48),
      );

  // Outlined Button
  static ButtonStyle get outlinedButton => OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMedium),
        ),
        minimumSize: const Size(64, 48),
      );

  // Text Button
  static ButtonStyle get textButton => TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusSmall),
        ),
        minimumSize: const Size(48, 40),
      );
}