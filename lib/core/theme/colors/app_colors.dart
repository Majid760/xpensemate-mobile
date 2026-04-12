import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// FinTrack — Light Theme Colors
// Brand palette:
//   Primary   #25C4C3  RGB(37,196,195)   — vibrant teal, CTAs & active states
//   Secondary #2E7692  RGB(46,118,146)   — deep ocean, headers & depth
//   Accent A  #22D7A4  RGB(34,215,164)   — mint green, success & income
//   Accent B  #20CE6F  RGB(32,206,111)   — fresh green, badges & tags
// ─────────────────────────────────────────────────────────────────────────────
abstract class AppColors {
  // ── Brand ─────────────────────────────────────────────────────────────────
  /// Vibrant teal — primary buttons, active nav, key numbers
  static const Color primary = Color.fromARGB(255, 25, 157, 157);

  /// Light teal tint — primary button backgrounds, chips
  static const Color primaryContainer = Color(0xFFB2F0EF);

  /// Deep ocean blue — secondary actions, chart fills, section headers
  static const Color secondary = Color(0xFF2E7692);

  /// Light sky tint — secondary chip/badge backgrounds
  static const Color secondaryContainer = Color(0xFFBEE3F0);

  /// Mint green — tertiary accent, income indicators, positive highlights
  static const Color tertiary = Color(0xFF22D7A4);

  /// Soft mint tint — tertiary chip backgrounds
  static const Color tertiaryContainer = Color(0xFFB2F5E2);

  // ── Surface ───────────────────────────────────────────────────────────────
  /// Pure white — main card & dialog surface
  static const Color surface = Color(0xFFFAF9F6);

  /// Warm off-white — input backgrounds, dividers, inactive surfaces
  static const Color surfaceVariant = Color(0xFFE0F4F4);

  /// Lightest teal tint page background — gives the app a fresh, airy feel
  static const Color surfaceContainer = Color(0xFFF0FAFA);

  /// Slightly deeper — elevated cards on page bg
  static const Color surfaceContainerHigh = Color(0xFFE4F5F5);

  /// Deepest surface — pressed/selected list items
  static const Color surfaceContainerHighest = Color(0xFFD5EEEE);

  /// App background — very subtle teal wash, not pure white
  static const Color background = Color(0xFFF5FAFA);

  // ── On-colors (text/icon on top of brand surfaces) ────────────────────────
  /// Text on primary — deep navy so teal CTA text is readable
  static const Color onPrimary = Color(0xFF003737);

  /// Text on primaryContainer — same deep navy
  static const Color onPrimaryContainer = Color(0xFF00201F);

  /// Text on secondary — white for contrast on deep ocean
  static const Color onSecondary = Color(0xFFFFFFFF);

  /// Text on secondaryContainer — deep blue-navy
  static const Color onSecondaryContainer = Color(0xFF001E2B);

  /// Text on tertiary — deep forest green
  static const Color onTertiary = Color(0xFF003828);

  /// Text on tertiaryContainer
  static const Color onTertiaryContainer = Color(0xFF002018);

  /// Primary body text — near-black with a faint warm tint
  static const Color onSurface = Color(0xFF0D1F2D);

  /// Secondary body text — medium slate
  static const Color onSurfaceVariant = Color(0xFF3D5A6A);

  /// Page-level text
  static const Color onBackground = Color(0xFF0D1F2D);

  // ── Error ─────────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFF410002);

  // ── Outline ───────────────────────────────────────────────────────────────
  /// Default border — medium teal-blue, used for input outlines & dividers
  static const Color outline = Color(0xFF2E7692);

  /// Subtle border — light teal, used for card edges & separators
  static const Color outlineVariant = Color(0xFFB2D8E8);

  // ── Semantic ─────────────────────────────────────────────────────────────
  /// Income, positive delta, savings growth
  static const Color success = Color(0xFF22D7A4);
  static const Color successContainer = Color(0xFFB2F5E2);
  static const Color onSuccess = Color(0xFF003828);
  static const Color onSuccessContainer = Color(0xFF002018);

  /// Budget warnings, near-limit alerts
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningContainer = Color(0xFFFEF3C7);
  static const Color onWarning = Color(0xFF422006);
  static const Color onWarningContainer = Color(0xFF422006);

  /// Informational states, tips, RAG responses
  static const Color info = Color(0xFF25C4C3);
  static const Color infoContainer = Color(0xFFB2F0EF);
  static const Color onInfo = Color(0xFF003737);
  static const Color onInfoContainer = Color(0xFF00201F);

  /// Expenditure, overspend, loss indicators
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerContainer = Color(0xFFFECFCF);
  static const Color onDanger = Color(0xFFFFFFFF);
  static const Color onDangerContainer = Color(0xFF7F1D1D);

  // ── Chart palette (ordered by visual weight) ──────────────────────────────
  /// Use these in order for multi-series charts so they stay on-brand
  static const Color chartPrimary   = Color(0xFF25C4C3); // teal
  static const Color chartSecondary = Color(0xFF2E7692); // deep ocean
  static const Color chartTertiary  = Color(0xFF22D7A4); // mint
  static const Color chartQuaternary= Color(0xFF20CE6F); // green
  static const Color chartNeutral   = Color(0xFFB4CDD6); // muted blue-gray

  // ── Scrim & overlay ───────────────────────────────────────────────────────
  static const Color scrim = Color(0xFF000000);
  static const Color shadow = Color(0xFF000000);
}