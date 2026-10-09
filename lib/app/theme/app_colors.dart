import 'package:flutter/material.dart';

/// Raw brand palette — the single source of truth for every colour value.
///
/// Nothing outside `app/theme/` imports this file. Widgets consume colours via
/// [ColorScheme] (Material roles) or `AppSemanticColors` (brand roles Material
/// does not model), so a dark scheme can be introduced in one place without
/// touching feature code.
abstract final class AppColors {
  // ── Primary — Bhagwa / Saffron ────────────────────────────────────────
  static const Color primary = Color(0xFFE8730C);
  static const Color primaryDark = Color(0xFFB4550A);
  static const Color primaryLight = Color(0xFFF59A4C);
  static const Color primaryContainer = Color(0xFFFBE7D2);

  // ── Secondary — Deep Blue ─────────────────────────────────────────────
  static const Color secondary = Color(0xFF1B3A6B);
  static const Color secondaryDark = Color(0xFF102A52);
  static const Color secondaryLight = Color(0xFF3E5C8A);
  static const Color secondaryContainer = Color(0xFFDCE6F6);

  // ── Accent — Maroon (devotional accent for tilaks / emphasis) ─────────
  static const Color maroon = Color(0xFF7A2E2E);

  // ── Surfaces ──────────────────────────────────────────────────────────
  static const Color background = Color(0xFFFDF9F3);
  static const Color surface = Color(0xFFFFFBF6);
  static const Color surfaceContainer = Color(0xFFF6EEE3);
  static const Color card = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFEADFD1);
  static const Color border = Color(0xFFD9CBBA);
  static const Color outline = Color(0xFF85736A);

  // ── Text ──────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1F1B16);
  static const Color textSecondary = Color(0xFF6B6157);
  static const Color textDisabled = Color(0xFFA99F94);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);

  // ── Feedback ──────────────────────────────────────────────────────────
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFB26A00);
  static const Color info = Color(0xFF01579B);
  static const Color error = Color(0xFFBA1A1A);

  // ── Tiers (achievements / leaderboards) ───────────────────────────────
  static const Color gold = Color(0xFFD4AF37);
  static const Color silver = Color(0xFFAAB2BD);
  static const Color bronze = Color(0xFFB08D57);

  /// Warm cream matching the upper region of the splash backdrop. Used to
  /// multiply-blend the white-backed wordmark so its box disappears into the
  /// splash canvas.
  static const Color splashCanvas = Color(0xFFFBF4E8);

  // ── Domain accents (temples / map) ────────────────────────────────────
  static const Color templeSand = Color(0xFFE8D5B5);
  static const Color templeStone = Color(0xFF9A8478);
  static const Color sky = Color(0xFF7EC8E3);
  static const Color mapGreen = Color(0xFF4C8C4A);

  /// Light [ColorScheme]. A `darkColorScheme` sibling is the single place a
  /// future dark theme plugs in.
  static final ColorScheme lightColorScheme = ColorScheme.fromSeed(
    seedColor: primary,
    primary: primary,
    onPrimary: onPrimary,
    primaryContainer: primaryContainer,
    secondary: secondary,
    onSecondary: onSecondary,
    secondaryContainer: secondaryContainer,
    tertiary: gold,
    error: error,
    surface: surface,
    onSurface: textPrimary,
    outline: outline,
    outlineVariant: border,
  );
}
