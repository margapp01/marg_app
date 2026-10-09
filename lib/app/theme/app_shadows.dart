import 'package:flutter/widgets.dart';

/// Elevation tokens as reusable [BoxShadow] lists. Kept subtle — most depth
/// comes from surface tones, not heavy shadows. Use these instead of ad-hoc
/// [BoxShadow]s so elevation reads consistently across the app.
abstract final class AppShadows {
  static const List<BoxShadow> none = <BoxShadow>[];

  /// Barely-there lift for chips, inputs, small tiles.
  static const List<BoxShadow> xs = <BoxShadow>[
    BoxShadow(color: Color(0x0D000000), blurRadius: 4, offset: Offset(0, 1)),
  ];

  /// Default card elevation.
  static const List<BoxShadow> sm = <BoxShadow>[
    BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2)),
  ];

  /// Raised cards, popovers.
  static const List<BoxShadow> md = <BoxShadow>[
    BoxShadow(color: Color(0x1A000000), blurRadius: 12, offset: Offset(0, 4)),
  ];

  /// Floating elements — FABs, bottom sheets, menus.
  static const List<BoxShadow> lg = <BoxShadow>[
    BoxShadow(color: Color(0x1F000000), blurRadius: 16, offset: Offset(0, 6)),
  ];

  /// Modal / dialog scrim-adjacent surfaces.
  static const List<BoxShadow> xl = <BoxShadow>[
    BoxShadow(color: Color(0x26000000), blurRadius: 28, offset: Offset(0, 12)),
  ];

  // ── Legacy aliases (kept so existing call sites keep compiling) ────────
  static const List<BoxShadow> card = sm;
  static const List<BoxShadow> floating = lg;

  /// Legibility shadow for light text set over photographs.
  static const List<Shadow> text = <Shadow>[
    Shadow(color: Color(0x99000000), blurRadius: 8, offset: Offset(0, 1)),
  ];
}
