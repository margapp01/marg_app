import 'package:flutter/material.dart';

import '../../app/theme/app_breakpoints.dart';
import '../../app/theme/app_palette.dart';
import '../../app/theme/app_theme.dart';
import '../../app/theme/app_typography.dart';

/// Ergonomic access to theme, semantic colours, typography, and responsive
/// info from any [BuildContext] — so widgets read `context.colors.gold` /
/// `context.textTheme.titleMedium` instead of long `Theme.of(context)` chains.
extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get scheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;

  // ── Typography — auxiliary styles not in [TextTheme] ──────────────────
  /// Small muted supporting text.
  TextStyle get caption => AppTypography.caption(scheme);

  /// Button label style (== `textTheme.labelLarge`).
  TextStyle get button => AppTypography.button(scheme);

  /// Tiny uppercase tracked section label.
  TextStyle get overline => AppTypography.overline(scheme);

  /// Brand (Cinzel) styles — **branding surfaces only** (splash, logo text,
  /// marketing, About, festival/promo headers). Never in forms, cards,
  /// buttons, lists, or paragraphs.
  AppBrandText get brandText =>
      Theme.of(this).extension<AppBrandText>() ?? AppTypography.brandText(scheme);

  /// Display serif (Playfair Display) — hero & ceremonial titles only.
  AppDisplayText get displayText =>
      Theme.of(this).extension<AppDisplayText>() ?? AppTypography.displayText(scheme);

  /// Illustrative palette: pastel tiles, accents, crowd colours.
  AppPalette get palette => Theme.of(this).extension<AppPalette>() ?? AppPalette.light;

  /// Brand colours Material doesn't model (gold, border, textSecondary, …).
  /// Never null in a themed subtree — [AppTheme] always registers it.
  AppSemanticColors get colors =>
      Theme.of(this).extension<AppSemanticColors>() ?? AppSemanticColors.light;

  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => MediaQuery.sizeOf(this);
  EdgeInsets get viewPadding => MediaQuery.viewPaddingOf(this);

  // ── Responsive ────────────────────────────────────────────────────────
  ScreenSize get sizeClass => AppBreakpoints.of(MediaQuery.sizeOf(this).width);
  bool get isCompact => sizeClass == ScreenSize.compact;
  bool get isTablet => sizeClass != ScreenSize.compact;
  bool get isLandscape =>
      MediaQuery.orientationOf(this) == Orientation.landscape;

  /// Picks a value per size class, falling back to smaller classes when a
  /// larger one isn't supplied. `context.responsive(compact: 1, expanded: 3)`.
  T responsive<T>({required T compact, T? medium, T? expanded}) {
    switch (sizeClass) {
      case ScreenSize.compact:
        return compact;
      case ScreenSize.medium:
        return medium ?? compact;
      case ScreenSize.expanded:
        return expanded ?? medium ?? compact;
    }
  }
}

/// Fluent tweaks on a themed [TextStyle] — recolour or restyle a role without
/// hardcoding a full style. Weight helpers are limited to the four approved
/// weights (Regular / Medium / SemiBold / Bold).
///
/// `context.textTheme.titleMedium!.semiBold.withColor(context.scheme.primary)`
extension TextStyleX on TextStyle {
  TextStyle get regular => copyWith(fontWeight: FontWeight.w400);
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);
  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);
  TextStyle get bold => copyWith(fontWeight: FontWeight.w700);

  TextStyle withColor(Color color) => copyWith(color: color);
}
