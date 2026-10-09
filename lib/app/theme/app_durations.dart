/// Animation duration tokens. Motion should feel light and purposeful — use
/// these so timing is consistent across every animated component.
abstract final class AppDurations {
  /// Micro-feedback: ripples, colour/opacity nudges.
  static const Duration fast = Duration(milliseconds: 150);

  /// Default UI transition: fades, small slides, expansions.
  static const Duration normal = Duration(milliseconds: 250);

  /// Emphasised movement: cards entering, sheets, page content.
  static const Duration slow = Duration(milliseconds: 400);

  /// Counters / progress fills that need to be legible as they animate.
  static const Duration counter = Duration(milliseconds: 800);

  /// Shimmer / skeleton sweep period.
  static const Duration shimmer = Duration(milliseconds: 1200);

  /// Base delay unit for staggered list entrances.
  static const Duration stagger = Duration(milliseconds: 60);

  /// The launch splash's brand moment (also its backdrop's settle-in zoom).
  static const Duration splash = Duration(milliseconds: 2400);
}
