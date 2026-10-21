import 'package:flutter/material.dart';

/// Raw brand palette — the single source of truth for every colour value.
///
/// Nothing outside `app/theme/` imports this file. Widgets consume colours via
/// [ColorScheme] (Material roles) or `AppSemanticColors` (brand roles Material
/// does not model), so a dark scheme can be introduced in one place without
/// touching feature code.
abstract final class AppColors {
  // ── Primary — Bhagwa / Saffron (the logo's path and temple) ───────────
  static const Color primary = Color(0xFFF76800);
  static const Color primaryDark = Color(0xFFC75200);
  static const Color primaryLight = Color(0xFFFF8A33);
  static const Color primaryContainer = Color(0xFFFFEDDF);

  // ── Secondary — Logo Navy (the logo's M) ──────────────────────────────
  static const Color secondary = Color(0xFF11224E);
  static const Color secondaryDark = Color(0xFF0A1636);
  static const Color secondaryLight = Color(0xFF2E4378);
  static const Color secondaryContainer = Color(0xFFE4E9F5);

  // ── Accent — Maroon (devotional accent for tilaks / emphasis) ─────────
  static const Color maroon = Color(0xFF7A2E2E);

  // ── Surfaces — clean white / off-white (no cream) ────────────────────
  static const Color background = Color(0xFFF7F8FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceContainer = Color(0xFFF0F2F6);
  static const Color card = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFE8EAF0);
  static const Color border = Color(0xFFD9DCE4);
  static const Color outline = Color(0xFF737889);

  // ── Text — navy-tinted ink ────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF141A2E);
  static const Color textSecondary = Color(0xFF5B6275);
  static const Color textDisabled = Color(0xFFA2A7B5);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);

  // ── Feedback ──────────────────────────────────────────────────────────
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFB26A00);
  static const Color info = Color(0xFF01579B);
  static const Color error = Color(0xFFBA1A1A);

  // ── Tiers (achievements / leaderboards) ───────────────────────────────
  static const Color gold = Color(0xFFD9A93A);
  static const Color silver = Color(0xFFAAB2BD);
  static const Color bronze = Color(0xFFB08D57);

  /// The splash / sign-in / setup canvas — pure white, so the white-backed
  /// wordmark sits on it without a visible box.
  static const Color splashCanvas = Color(0xFFFFFFFF);

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
    onSurfaceVariant: textSecondary,
    outline: outline,
    outlineVariant: border,
    // Neutral containers — the saffron seed would otherwise tint every
    // Material surface (sheets, menus, nav bar) peach.
    surfaceTint: Colors.transparent,
    surfaceContainerLowest: card,
    surfaceContainerLow: background,
    surfaceContainer: surfaceContainer,
    surfaceContainerHigh: Color(0xFFE9ECF2),
    surfaceContainerHighest: Color(0xFFE2E6EE),
  );
}
