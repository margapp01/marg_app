import 'package:flutter/material.dart';

import '../../app/theme/app_curves.dart';
import '../../app/theme/app_durations.dart';
import '../../app/theme/app_radius.dart';
import '../../core/extensions/context_extensions.dart';

/// A rounded linear progress bar that animates to [value] (0–1). Used for
/// passport / temple completion, upload progress, etc.
class AppLinearProgress extends StatelessWidget {
  const AppLinearProgress({
    required this.value,
    this.height = 8,
    this.color,
    this.backgroundColor,
    this.duration = AppDurations.slow,
    super.key,
  });

  final double value;
  final double height;
  final Color? color;
  final Color? backgroundColor;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final fg = color ?? context.scheme.primary;
    final bg = backgroundColor ?? context.colors.divider;
    return Semantics(
      value: '${(value.clamp(0.0, 1.0) * 100).round()}%',
      child: ClipRRect(
        borderRadius: AppRadius.fullAll,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: value.clamp(0.0, 1.0)),
          duration: duration,
          curve: AppCurves.emphasize,
          builder: (context, v, _) => LinearProgressIndicator(
            value: v,
            minHeight: height,
            color: fg,
            backgroundColor: bg,
          ),
        ),
      ),
    );
  }
}

/// A circular progress ring that animates to [value] (0–1), with an optional
/// centred label — completion rings, score dials.
class AppCircularProgress extends StatelessWidget {
  const AppCircularProgress({
    required this.value,
    this.size = 64,
    this.strokeWidth = 6,
    this.color,
    this.backgroundColor,
    this.center,
    this.duration = AppDurations.slow,
    super.key,
  });

  final double value;
  final double size;
  final double strokeWidth;
  final Color? color;
  final Color? backgroundColor;
  final Widget? center;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final fg = color ?? context.scheme.primary;
    final bg = backgroundColor ?? context.colors.divider;
    return SizedBox.square(
      dimension: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: value.clamp(0.0, 1.0)),
        duration: duration,
        curve: AppCurves.emphasize,
        builder: (context, v, _) => Stack(
          alignment: Alignment.center,
          children: [
            SizedBox.square(
              dimension: size,
              child: CircularProgressIndicator(
                value: v,
                strokeWidth: strokeWidth,
                color: fg,
                backgroundColor: bg,
                strokeCap: StrokeCap.round,
              ),
            ),
            ?center,
          ],
        ),
      ),
    );
  }
}
