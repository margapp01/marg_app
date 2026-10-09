import 'package:flutter/widgets.dart';

/// Corner-radius tokens. Prefer the pre-built [BorderRadius] constants so call
/// sites never construct radii from magic numbers.
abstract final class AppRadius {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double full = 999;

  static const BorderRadius xsAll = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlAll = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius fullAll = BorderRadius.all(Radius.circular(full));

  /// Rounds only the top edge — sheets, banners, image headers.
  static const BorderRadius topLg = BorderRadius.only(
    topLeft: Radius.circular(lg),
    topRight: Radius.circular(lg),
  );
  static const BorderRadius topXl = BorderRadius.only(
    topLeft: Radius.circular(xl),
    topRight: Radius.circular(xl),
  );

  // ── Semantic radii — pick by role so shapes stay consistent app-wide ──
  /// Cards, tiles, panels, banners.
  static const BorderRadius card = lgAll;

  /// Text inputs and the search pill — same rounding as cards so forms and
  /// search read as one family.
  static const BorderRadius input = lgAll;

  /// Buttons and other tappable controls.
  static const BorderRadius control = mdAll;

  /// Thumbnails and icon tiles nested inside cards.
  static const BorderRadius thumb = mdAll;

  /// Chips, tags, badges, toggles.
  static const BorderRadius pill = fullAll;

  /// Dialogs and hero sheets.
  static const BorderRadius dialog = xlAll;
}
