import 'package:flutter/animation.dart';

/// Animation easing tokens. Prefer these named curves over raw [Curves] so
/// motion character stays consistent (calm, premium — never bouncy or harsh).
abstract final class AppCurves {
  /// Standard easing for most transitions (Material emphasized-decelerate feel).
  static const Cubic standard = Cubic(0.2, 0.0, 0.0, 1.0);

  /// Elements entering the screen (decelerate).
  static const Cubic enter = Cubic(0.05, 0.7, 0.1, 1.0);

  /// Elements leaving the screen (accelerate).
  static const Cubic exit = Cubic(0.3, 0.0, 0.8, 0.15);

  /// Gentle emphasis for counters / progress.
  static const Curve emphasize = Curves.easeInOutCubic;

  /// A restrained overshoot for success / badge pops (subtle, not playful).
  static const Curve pop = Curves.easeOutBack;
}
