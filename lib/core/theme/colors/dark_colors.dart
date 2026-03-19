import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// FinTrack — Dark Theme Colors
// Dark backgrounds are deep navy-teal (not pure black) so the brand colors
// feel warm and cohesive rather than floating on a void.
//   Background layers: #0D1F2D → #122436 → #193148 → #1E3A55
//   Brand colors shift to their lighter tints for dark surfaces
// ─────────────────────────────────────────────────────────────────────────────
class DarkColors {
  static ColorScheme get colorScheme => const ColorScheme.dark(
        primary: AppDarkColors.primary,
        onPrimary: AppDarkColors.onPrimary,
        primaryContainer: AppDarkColors.primaryContainer,
        onPrimaryContainer: AppDarkColors.onPrimaryContainer,
        secondary: AppDarkColors.secondary,
        onSecondary: AppDarkColors.onSecondary,
        secondaryContainer: AppDarkColors.secondaryContainer,
        onSecondaryContainer: AppDarkColors.onSecondaryContainer,
        tertiary: AppDarkColors.tertiary,
        onTertiary: AppDarkColors.onTertiary,
        tertiaryContainer: AppDarkColors.tertiaryContainer,
        onTertiaryContainer: AppDarkColors.onTertiaryContainer,
        error: AppDarkColors.error,
        onError: AppDarkColors.onError,
        errorContainer: AppDarkColors.errorContainer,
        onErrorContainer: AppDarkColors.onErrorContainer,
        surface: AppDarkColors.surface,
        onSurface: AppDarkColors.onSurface,
        onSurfaceVariant: AppDarkColors.onSurfaceVariant,
        outline: AppDarkColors.outline,
        outlineVariant: AppDarkColors.outlineVariant,
        surfaceContainerHighest: AppDarkColors.surfaceContainerHighest,
        scrim: AppDarkColors.scrim,
        shadow: AppDarkColors.shadow,
      );
}

final class AppDarkColors {
  // ── Brand ─────────────────────────────────────────────────────────────────
  /// Teal — stays bright on dark bg, primary actions & key numbers
  static const Color primary = Color(0xFF25C4C3);

  /// Deep teal container — pill/chip bg behind teal text
  static const Color primaryContainer = Color(0xFF0A4040);

  /// Deep ocean — used for secondary UI chrome, chart bars
  static const Color secondary = Color(0xFF7CC8DF);

  /// Dark ocean container — chip/badge bg
  static const Color secondaryContainer = Color(0xFF0E3A4A);

  /// Mint — income, positive deltas, highlights
  static const Color tertiary = Color(0xFF22D7A4);

  /// Dark mint container
  static const Color tertiaryContainer = Color(0xFF083D28);

  // ── Surface layers (navy-teal family) ─────────────────────────────────────
  /// Main card surface — deep navy-teal
  static const Color surface = Color(0xFF122436);

  /// Input / inactive surface
  static const Color surfaceVariant = Color(0xFF193148);

  /// Page background — darkest layer
  static const Color surfaceContainer = Color(0xFF0D1F2D);

  /// Elevated cards on page bg
  static const Color surfaceContainerHigh = Color(0xFF193148);

  /// Pressed/selected items — lightest dark surface
  static const Color surfaceContainerHighest = Color(0xFF1E3A55);

  /// App background
  static const Color background = Color(0xFF0D1F2D);

  // ── On-colors ─────────────────────────────────────────────────────────────
  /// Text on primary teal — deep navy for contrast
  static const Color onPrimary = Color(0xFF003737);

  /// Text on primaryContainer — bright teal tint
  static const Color onPrimaryContainer = Color(0xFF9FF0EF);

  /// Text on secondary
  static const Color onSecondary = Color(0xFF003547);

  /// Text on secondaryContainer — light sky
  static const Color onSecondaryContainer = Color(0xFFB2E8F8);

  /// Text on tertiary
  static const Color onTertiary = Color(0xFF003828);

  /// Text on tertiaryContainer — light mint
  static const Color onTertiaryContainer = Color(0xFF9FF5D8);

  /// Primary body text — near-white with warm tint
  static const Color onSurface = Color(0xFFE2F0F0);

  /// Secondary body text — muted teal-white
  static const Color onSurfaceVariant = Color(0xFF8FBBCC);

  /// Page-level text
  static const Color onBackground = Color(0xFFE2F0F0);

  // ── Error ─────────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFFFB4AB);
  static const Color errorContainer = Color(0xFF93000A);
  static const Color onError = Color(0xFF690005);
  static const Color onErrorContainer = Color(0xFFFFDAD6);

  // ── Outline ───────────────────────────────────────────────────────────────
  /// Default border — medium teal, visible on dark surfaces
  static const Color outline = Color(0xFF25C4C3);

  /// Subtle border — dim teal, card edges & separators
  static const Color outlineVariant = Color(0xFF1E4A5A);

  // ── Semantic ─────────────────────────────────────────────────────────────
  /// Income, positive delta — bright mint on dark bg
  static const Color success = Color(0xFF22D7A4);
  static const Color successContainer = Color(0xFF083D28);
  static const Color onSuccess = Color(0xFF003828);
  static const Color onSuccessContainer = Color(0xFF9FF5D8);

  /// Budget warning
  static const Color warning = Color(0xFFFCD34D);
  static const Color warningContainer = Color(0xFF3D2000);
  static const Color onWarning = Color(0xFF3D2000);
  static const Color onWarningContainer = Color(0xFFFEF3C7);

  /// Info / RAG responses
  static const Color info = Color(0xFF7CC8DF);
  static const Color infoContainer = Color(0xFF0E3A4A);
  static const Color onInfo = Color(0xFF003547);
  static const Color onInfoContainer = Color(0xFFB2E8F8);

  /// Expenditure, overspend, loss
  static const Color danger = Color(0xFFFCA5A5);
  static const Color dangerContainer = Color(0xFF7F1D1D);
  static const Color onDanger = Color(0xFF690005);
  static const Color onDangerContainer = Color(0xFFFECFCF);

  // ── Chart palette ─────────────────────────────────────────────────────────
  static const Color chartPrimary    = Color(0xFF25C4C3); // teal
  static const Color chartSecondary  = Color(0xFF7CC8DF); // light ocean
  static const Color chartTertiary   = Color(0xFF22D7A4); // mint
  static const Color chartQuaternary = Color(0xFF20CE6F); // green
  static const Color chartNeutral    = Color(0xFF3A5A6A); // muted

  // ── Scrim & overlay ───────────────────────────────────────────────────────
  static const Color scrim = Color(0xFF000000);
  static const Color shadow = Color(0xFF000000);
}