import 'package:flutter/material.dart';

/// The vibrant, illustrative side of the MARG palette used by the redesigned
/// screens: pastel tile tints for quick-action tiles, accent hues for icons and
/// progress, and crowd-level colours. Read via `context.palette`.
///
/// Kept as its own [ThemeExtension] (separate from `AppSemanticColors`) so a
/// dark theme can tune these illustrative colours independently.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.tilePeach,
    required this.tileLavender,
    required this.tileMint,
    required this.tileSky,
    required this.tileRose,
    required this.tileButter,
    required this.accentSaffron,
    required this.accentViolet,
    required this.accentTeal,
    required this.accentBlue,
    required this.accentRose,
    required this.accentAmber,
    required this.accentGreen,
    required this.crowdLow,
    required this.crowdModerate,
    required this.crowdHigh,
    required this.crowdVeryHigh,
    required this.heroCream,
    required this.night,
  });

  // ── Pastel tile tints ────────────────────────────────────────────────
  final Color tilePeach;
  final Color tileLavender;
  final Color tileMint;
  final Color tileSky;
  final Color tileRose;
  final Color tileButter;

  // ── Accent hues (icons, progress bars, chips) ────────────────────────
  final Color accentSaffron;
  final Color accentViolet;
  final Color accentTeal;
  final Color accentBlue;
  final Color accentRose;
  final Color accentAmber;
  final Color accentGreen;

  // ── Crowd levels (Temple Intelligence) ───────────────────────────────
  final Color crowdLow;
  final Color crowdModerate;
  final Color crowdHigh;
  final Color crowdVeryHigh;

  /// The light canvas behind hero imagery (white — the app has no cream).
  final Color heroCream;

  /// Deep night-sky navy for dark showcase cards (card unlock, share cards).
  final Color night;

  static const AppPalette light = AppPalette(
    tilePeach: Color(0xFFFDEBDD),
    tileLavender: Color(0xFFEFEAFC),
    tileMint: Color(0xFFE3F4EA),
    tileSky: Color(0xFFE3F0FB),
    tileRose: Color(0xFFFCE6EA),
    tileButter: Color(0xFFFDF3D6),
    accentSaffron: Color(0xFFF76800),
    accentViolet: Color(0xFF7B5CD6),
    accentTeal: Color(0xFF239A8A),
    accentBlue: Color(0xFF2F80ED),
    accentRose: Color(0xFFE04F6A),
    accentAmber: Color(0xFFD99A00),
    accentGreen: Color(0xFF2E9D57),
    crowdLow: Color(0xFF2E9D57),
    crowdModerate: Color(0xFFD99A00),
    crowdHigh: Color(0xFFE2574C),
    crowdVeryHigh: Color(0xFF7B5CD6),
    heroCream: Color(0xFFFFFFFF),
    night: Color(0xFF0E1C44),
  );

  /// The palette is a fixed token set; themes swap whole instances.
  @override
  AppPalette copyWith() => this;

  @override
  AppPalette lerp(AppPalette? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t) ?? a;
    return AppPalette(
      tilePeach: l(tilePeach, other.tilePeach),
      tileLavender: l(tileLavender, other.tileLavender),
      tileMint: l(tileMint, other.tileMint),
      tileSky: l(tileSky, other.tileSky),
      tileRose: l(tileRose, other.tileRose),
      tileButter: l(tileButter, other.tileButter),
      accentSaffron: l(accentSaffron, other.accentSaffron),
      accentViolet: l(accentViolet, other.accentViolet),
      accentTeal: l(accentTeal, other.accentTeal),
      accentBlue: l(accentBlue, other.accentBlue),
      accentRose: l(accentRose, other.accentRose),
      accentAmber: l(accentAmber, other.accentAmber),
      accentGreen: l(accentGreen, other.accentGreen),
      crowdLow: l(crowdLow, other.crowdLow),
      crowdModerate: l(crowdModerate, other.crowdModerate),
      crowdHigh: l(crowdHigh, other.crowdHigh),
      crowdVeryHigh: l(crowdVeryHigh, other.crowdVeryHigh),
      heroCream: l(heroCream, other.heroCream),
      night: l(night, other.night),
    );
  }
}

/// Gradient tokens for the redesigned surfaces (CTAs, hero fades, showcase
/// cards). Like [AppShadows], these are const tokens referenced directly.
abstract final class AppGradients {
  /// Saffron call-to-action fill — the logo path's orange sweep.
  static const LinearGradient primary = LinearGradient(
    colors: [Color(0xFFFF8A1F), Color(0xFFF76800)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Fades hero imagery into the page background (left → right).
  static const LinearGradient heroFade = LinearGradient(
    colors: [Color(0xFFF7F8FA), Color(0xE6F7F8FA), Color(0x00F7F8FA)],
    stops: [0, 0.45, 0.8],
  );

  /// Fades a hero into the page at its bottom edge.
  static const LinearGradient heroBottomFade = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x00F7F8FA), Color(0xFFF7F8FA)],
  );

  /// Dark scrim for text over photos (bottom-up).
  static const LinearGradient photoScrim = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [Color(0xD9000000), Color(0x33000000), Color(0x00000000)],
    stops: [0, 0.55, 1],
  );

  /// Dark scrim for text over photos (left → right).
  static const LinearGradient photoScrimLeft = LinearGradient(
    colors: [Color(0xCC000000), Color(0x40000000), Color(0x00000000)],
    stops: [0, 0.6, 1],
  );

  /// White with a whisper of saffron for quote / blessing / hub cards.
  static const LinearGradient parchment = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFFFF3E8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Soft saffron wash for promo cards (Invite & Earn, Need Help).
  static const LinearGradient peach = LinearGradient(
    colors: [Color(0xFFFFF6EE), Color(0xFFFFE3CC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// The logo's navy for passport / progress showcase cards.
  static const LinearGradient navy = LinearGradient(
    colors: [Color(0xFF1A3170), Color(0xFF0A1636)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Burnished gold leaf — the frame of a Sacred Card.
  static const LinearGradient gilt = LinearGradient(
    colors: [Color(0xFFF7E7A8), Color(0xFFD4AF37), Color(0xFFA67C1E), Color(0xFFE8C766)],
    stops: [0, 0.35, 0.7, 1],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Weathered sandstone — the frame of a locked Sacred Card.
  static const LinearGradient stone = LinearGradient(
    colors: [Color(0xFFEDE5D8), Color(0xFFCFC3B1), Color(0xFFE4DACB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Night sky (logo navy) for card-unlock / share showcase surfaces.
  static const LinearGradient night = LinearGradient(
    colors: [Color(0xFF1C3375), Color(0xFF081231)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
