/// Responsive size classes. Layouts adapt by class, never by hard-coded pixel
/// widths — see the `context.sizeClass` / `context.responsive` helpers.
enum ScreenSize { compact, medium, expanded }

/// Width breakpoints (logical px). Aligned with Material 3 window classes.
abstract final class AppBreakpoints {
  /// Small / normal phones.
  static const double compact = 600;

  /// Large phones, foldables, small tablets (portrait).
  static const double medium = 840;

  /// Tablets, landscape, desktop.
  static const double expanded = 1200;

  /// Content never stretches wider than this — keeps text lines readable on
  /// tablets/foldables.
  static const double maxContentWidth = 720;

  static ScreenSize of(double width) {
    if (width < compact) return ScreenSize.compact;
    if (width < medium) return ScreenSize.medium;
    return ScreenSize.expanded;
  }
}
