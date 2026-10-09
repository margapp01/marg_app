import 'package:flutter/widgets.dart';

import '../../app/theme/app_curves.dart';
import '../../app/theme/app_durations.dart';

/// Counts up (or down) to [value] whenever it changes — points, visit counts,
/// trust score. Re-animates from the previous value on rebuild.
class AnimatedCount extends StatelessWidget {
  const AnimatedCount({
    required this.value,
    this.duration = AppDurations.counter,
    this.style,
    this.prefix = '',
    this.suffix = '',
    this.formatter,
    super.key,
  });

  final int value;
  final Duration duration;
  final TextStyle? style;
  final String prefix;
  final String suffix;

  /// Formats the interpolated integer (e.g. thousands separators). Defaults to
  /// `toString()`.
  final String Function(int)? formatter;

  @override
  Widget build(BuildContext context) {
    final format = formatter ?? (v) => v.toString();
    // Reduce Animations → snap straight to the value (no count-up).
    final d = MediaQuery.of(context).disableAnimations ? Duration.zero : duration;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value.toDouble()),
      duration: d,
      curve: AppCurves.emphasize,
      builder: (context, v, _) =>
          Text('$prefix${format(v.round())}$suffix', style: style),
    );
  }
}

/// Animated fractional number (e.g. distance, rating) with fixed decimals.
class AnimatedNumber extends StatelessWidget {
  const AnimatedNumber({
    required this.value,
    this.fractionDigits = 1,
    this.duration = AppDurations.counter,
    this.style,
    this.prefix = '',
    this.suffix = '',
    super.key,
  });

  final double value;
  final int fractionDigits;
  final Duration duration;
  final TextStyle? style;
  final String prefix;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    final d = MediaQuery.of(context).disableAnimations ? Duration.zero : duration;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: d,
      curve: AppCurves.emphasize,
      builder: (context, v, _) =>
          Text('$prefix${v.toStringAsFixed(fractionDigits)}$suffix', style: style),
    );
  }
}
