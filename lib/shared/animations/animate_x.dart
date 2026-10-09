import 'package:flutter/widgets.dart';

import '../../app/theme/app_durations.dart';
import 'app_entrance.dart';

/// Fluent entrance animations on any widget:
/// `Text('Hi').fadeIn()`, `card.slideIn(delay: 100.ms)`.
///
/// Thin wrappers over [AppEntrance] so call sites stay terse while timing and
/// easing remain centralised.
extension AnimateX on Widget {
  Widget fadeIn({
    Duration duration = AppDurations.normal,
    Duration delay = Duration.zero,
  }) =>
      FadeIn(duration: duration, delay: delay, child: this);

  Widget scaleIn({
    Duration duration = AppDurations.normal,
    Duration delay = Duration.zero,
    double from = 0.92,
  }) =>
      ScaleIn(duration: duration, delay: delay, from: from, child: this);

  Widget slideIn({
    Duration duration = AppDurations.normal,
    Duration delay = Duration.zero,
    Offset from = const Offset(0, 24),
  }) =>
      SlideIn(duration: duration, delay: delay, from: from, child: this);
}

/// `200.ms` / `2.seconds` for readable animation timing at call sites.
extension DurationX on int {
  Duration get ms => Duration(milliseconds: this);
  Duration get seconds => Duration(seconds: this);
}
