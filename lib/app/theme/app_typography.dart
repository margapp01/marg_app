import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_breakpoints.dart';

/// The MARG typography system — Material 3 scale with a premium spiritual
/// identity. Two families only:
///
/// * **Noto Sans** — the entire UI (buttons, cards, inputs, temple names,
///   descriptions, lists, navigation, every screen). Hindi renders through the
///   **Noto Sans Devanagari** fallback on the same [TextStyle], so language
///   switches are seamless.
/// * **Cinzel** — branding **only** (splash title, logo text, marketing
///   headlines, About, festival headers, promo banners). Reach for it via
///   `context.brandText`; never inside forms, cards, buttons, lists, or
///   paragraphs.
///
/// Weights are limited to Regular / Medium / SemiBold / Bold. Sizes live here
/// and nowhere else — widgets read `context.textTheme.*` (+ [context.caption]/
/// [context.button]/[context.overline]/[context.brandText]) and never set
/// `fontSize`/`fontWeight`/`fontFamily` directly. Sizes scale responsively via
/// [responsiveTextScaler] (device size × the user's accessibility setting).
abstract final class AppTypography {
  // ── Families ──────────────────────────────────────────────────────────
  static String get uiFamily => GoogleFonts.notoSans().fontFamily!;
  static String get devanagariFamily =>
      GoogleFonts.notoSansDevanagari().fontFamily!;
  static String get brandFamily => GoogleFonts.cinzel().fontFamily!;
  static String get displayFamily => GoogleFonts.playfairDisplay().fontFamily!;

  static List<String> get _fallback => <String>[devanagariFamily];

  // ── Allowed weights ───────────────────────────────────────────────────
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  /// The full UI text theme (Noto Sans, Devanagari fallback). Roles carry
  /// readable line heights and restrained letter spacing for older users.
  static TextTheme textTheme(ColorScheme scheme) {
    final base = GoogleFonts.notoSansTextTheme(
      Typography.material2021(colorScheme: scheme).black,
    );
    final scaled = base.copyWith(
      displayLarge: base.displayLarge?.copyWith(fontWeight: semiBold, height: 1.12, letterSpacing: -0.25),
      displayMedium: base.displayMedium?.copyWith(fontWeight: semiBold, height: 1.14, letterSpacing: -0.2),
      displaySmall: base.displaySmall?.copyWith(fontWeight: semiBold, height: 1.16),
      headlineLarge: base.headlineLarge?.copyWith(fontWeight: semiBold, height: 1.2),
      headlineMedium: base.headlineMedium?.copyWith(fontWeight: semiBold, height: 1.22),
      headlineSmall: base.headlineSmall?.copyWith(fontWeight: semiBold, height: 1.25),
      titleLarge: base.titleLarge?.copyWith(fontWeight: semiBold, height: 1.28),
      titleMedium: base.titleMedium?.copyWith(fontWeight: semiBold, height: 1.3, letterSpacing: 0.1),
      titleSmall: base.titleSmall?.copyWith(fontWeight: medium, height: 1.3, letterSpacing: 0.1),
      bodyLarge: base.bodyLarge?.copyWith(fontWeight: regular, height: 1.5, letterSpacing: 0.15),
      bodyMedium: base.bodyMedium?.copyWith(fontWeight: regular, height: 1.5, letterSpacing: 0.2),
      bodySmall: base.bodySmall?.copyWith(fontWeight: regular, height: 1.45, letterSpacing: 0.2),
      labelLarge: base.labelLarge?.copyWith(fontWeight: semiBold, height: 1.2, letterSpacing: 0.1),
      labelMedium: base.labelMedium?.copyWith(fontWeight: medium, height: 1.2, letterSpacing: 0.4),
      labelSmall: base.labelSmall?.copyWith(fontWeight: medium, height: 1.2, letterSpacing: 0.4),
    );
    return scaled.apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
      fontFamilyFallback: _fallback,
    );
  }

  // ── Auxiliary UI styles not modelled by [TextTheme] ───────────────────
  /// Small muted supporting text (timestamps, helper text).
  static TextStyle caption(ColorScheme scheme) => TextStyle(
        fontFamily: uiFamily,
        fontFamilyFallback: _fallback,
        fontSize: 11,
        height: 1.35,
        letterSpacing: 0.4,
        fontWeight: regular,
        color: scheme.onSurfaceVariant,
      );

  /// Button label style (== the Material button role, [TextTheme.labelLarge]).
  static TextStyle button(ColorScheme scheme) => TextStyle(
        fontFamily: uiFamily,
        fontFamilyFallback: _fallback,
        fontSize: 14,
        height: 1.2,
        letterSpacing: 0.1,
        fontWeight: semiBold,
        color: scheme.onSurface,
      );

  /// Tiny uppercase tracked label above a section/group.
  static TextStyle overline(ColorScheme scheme) => TextStyle(
        fontFamily: uiFamily,
        fontFamilyFallback: _fallback,
        fontSize: 10,
        height: 1.6,
        letterSpacing: 1.5,
        fontWeight: medium,
        color: scheme.onSurfaceVariant,
      );

  // ── Brand (Cinzel) — branding only ────────────────────────────────────
  static AppBrandText brandText(ColorScheme scheme) {
    TextStyle cinzel(double size, FontWeight weight, {double height = 1.15}) =>
        GoogleFonts.cinzel(
          textStyle: TextStyle(
            fontSize: size,
            fontWeight: weight,
            height: height,
            letterSpacing: 0.5,
            color: scheme.onSurface,
          ),
        ).copyWith(fontFamilyFallback: _fallback);
    return AppBrandText(
      displayLarge: cinzel(40, bold),
      displayMedium: cinzel(32, bold),
      displaySmall: cinzel(28, semiBold),
      headlineLarge: cinzel(26, semiBold),
      headlineMedium: cinzel(22, semiBold),
      headlineSmall: cinzel(20, semiBold),
      // Small caps-style lines: taglines, credits, ceremonial labels.
      titleMedium: cinzel(15, semiBold),
      labelLarge: cinzel(12, semiBold),
    );
  }

  // ── Display serif (Playfair Display) — page heroes & ceremonial titles ──
  /// Elegant serif for large, sparse headlines the designs set in serif:
  /// welcome / onboarding titles, hero names (temple, card, achievement,
  /// devotee), certificates and celebrations. Never for body text, lists,
  /// buttons or form labels — those stay Noto Sans.
  static AppDisplayText displayText(ColorScheme scheme) {
    TextStyle serif(double size, FontWeight weight, {double height = 1.2}) =>
        GoogleFonts.playfairDisplay(
          textStyle: TextStyle(
            fontSize: size,
            fontWeight: weight,
            height: height,
            color: scheme.secondary,
          ),
        ).copyWith(fontFamilyFallback: _fallback);
    return AppDisplayText(
      displaySmall: serif(34, bold, height: 1.12),
      headlineLarge: serif(28, bold),
      headlineMedium: serif(24, bold),
      headlineSmall: serif(20, bold),
      titleLarge: serif(18, semiBold),
    );
  }

  /// A responsive [TextScaler] combining a subtle device-size factor with the
  /// user's accessibility text scale, clamped to a readable range so large
  /// text is supported without breaking layouts. Applied once at the app root
  /// (see `MargApp`'s builder), so every `context.textTheme` style scales.
  static TextScaler responsiveTextScaler(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final deviceFactor = switch (AppBreakpoints.of(width)) {
      ScreenSize.compact => 1.0,
      ScreenSize.medium => 1.03,
      ScreenSize.expanded => 1.06,
    };
    final userScale = MediaQuery.textScalerOf(context).scale(1);
    final combined = (userScale * deviceFactor).clamp(1.0, 1.6);
    return TextScaler.linear(combined);
  }
}

/// Brand (Cinzel) text styles, exposed as a [ThemeExtension] so branding reads
/// `context.brandText.displayLarge` and adapts with the active scheme (and a
/// future dark theme). Use for branding surfaces only.
@immutable
class AppBrandText extends ThemeExtension<AppBrandText> {
  const AppBrandText({
    required this.displayLarge,
    required this.displayMedium,
    required this.displaySmall,
    required this.headlineLarge,
    required this.headlineMedium,
    required this.headlineSmall,
    required this.titleMedium,
    required this.labelLarge,
  });

  final TextStyle displayLarge;
  final TextStyle displayMedium;
  final TextStyle displaySmall;
  final TextStyle headlineLarge;
  final TextStyle headlineMedium;
  final TextStyle headlineSmall;
  final TextStyle titleMedium;
  final TextStyle labelLarge;

  @override
  AppBrandText copyWith({
    TextStyle? displayLarge,
    TextStyle? displayMedium,
    TextStyle? displaySmall,
    TextStyle? headlineLarge,
    TextStyle? headlineMedium,
    TextStyle? headlineSmall,
    TextStyle? titleMedium,
    TextStyle? labelLarge,
  }) {
    return AppBrandText(
      displayLarge: displayLarge ?? this.displayLarge,
      displayMedium: displayMedium ?? this.displayMedium,
      displaySmall: displaySmall ?? this.displaySmall,
      headlineLarge: headlineLarge ?? this.headlineLarge,
      headlineMedium: headlineMedium ?? this.headlineMedium,
      headlineSmall: headlineSmall ?? this.headlineSmall,
      titleMedium: titleMedium ?? this.titleMedium,
      labelLarge: labelLarge ?? this.labelLarge,
    );
  }

  @override
  AppBrandText lerp(AppBrandText? other, double t) {
    if (other == null) return this;
    return AppBrandText(
      displayLarge: TextStyle.lerp(displayLarge, other.displayLarge, t)!,
      displayMedium: TextStyle.lerp(displayMedium, other.displayMedium, t)!,
      displaySmall: TextStyle.lerp(displaySmall, other.displaySmall, t)!,
      headlineLarge: TextStyle.lerp(headlineLarge, other.headlineLarge, t)!,
      headlineMedium: TextStyle.lerp(headlineMedium, other.headlineMedium, t)!,
      headlineSmall: TextStyle.lerp(headlineSmall, other.headlineSmall, t)!,
      titleMedium: TextStyle.lerp(titleMedium, other.titleMedium, t)!,
      labelLarge: TextStyle.lerp(labelLarge, other.labelLarge, t)!,
    );
  }
}

/// Display serif styles (Playfair Display), exposed as a [ThemeExtension] so
/// screens read `context.displayText.headlineMedium`. Hero/ceremonial titles
/// only — see [AppTypography.displayText].
@immutable
class AppDisplayText extends ThemeExtension<AppDisplayText> {
  const AppDisplayText({
    required this.displaySmall,
    required this.headlineLarge,
    required this.headlineMedium,
    required this.headlineSmall,
    required this.titleLarge,
  });

  final TextStyle displaySmall;
  final TextStyle headlineLarge;
  final TextStyle headlineMedium;
  final TextStyle headlineSmall;
  final TextStyle titleLarge;

  @override
  AppDisplayText copyWith() => this;

  @override
  AppDisplayText lerp(AppDisplayText? other, double t) {
    if (other == null) return this;
    return AppDisplayText(
      displaySmall: TextStyle.lerp(displaySmall, other.displaySmall, t)!,
      headlineLarge: TextStyle.lerp(headlineLarge, other.headlineLarge, t)!,
      headlineMedium: TextStyle.lerp(headlineMedium, other.headlineMedium, t)!,
      headlineSmall: TextStyle.lerp(headlineSmall, other.headlineSmall, t)!,
      titleLarge: TextStyle.lerp(titleLarge, other.titleLarge, t)!,
    );
  }
}
