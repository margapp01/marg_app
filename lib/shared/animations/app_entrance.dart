import 'package:flutter/material.dart';

import '../../app/theme/app_curves.dart';
import '../../app/theme/app_durations.dart';

/// A one-shot entrance animation: fades, scales, and/or slides its [child] in
/// when first built (optionally after [delay]). The single primitive behind
/// [FadeIn], [ScaleIn], [SlideIn] and the `Widget.animate*` extension, so all
/// entrance motion shares timing and easing.
///
/// Purposeful, not decorative — use for content appearing, list items, cards.
class AppEntrance extends StatefulWidget {
  const AppEntrance({
    required this.child,
    this.duration = AppDurations.normal,
    this.delay = Duration.zero,
    this.curve = AppCurves.enter,
    this.fromOpacity = 0,
    this.fromScale = 1,
    this.fromOffset = Offset.zero,
    super.key,
  });

  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;

  /// Starting opacity (0 = fade in). Always animates to 1.
  final double fromOpacity;

  /// Starting scale (e.g. 0.92 = grow in). Always animates to 1.
  final double fromScale;

  /// Starting translation in logical px (e.g. Offset(0, 24) = rise up).
  final Offset fromOffset;

  @override
  State<AppEntrance> createState() => _AppEntranceState();
}

class _AppEntranceState extends State<AppEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late final Animation<double> _t =
      CurvedAnimation(parent: _controller, curve: widget.curve);

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future<void>.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Respect "Reduce Animations" (user preference or platform setting): show
    // the final state immediately, skipping the entrance motion entirely.
    if (MediaQuery.of(context).disableAnimations) return widget.child;
    return AnimatedBuilder(
      animation: _t,
      builder: (context, child) {
        final v = _t.value;
        final opacity = widget.fromOpacity + (1 - widget.fromOpacity) * v;
        final scale = widget.fromScale + (1 - widget.fromScale) * v;
        final offset = Offset.lerp(widget.fromOffset, Offset.zero, v)!;
        return Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: offset,
            child: Transform.scale(scale: scale, child: child),
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// Fades [child] in.
class FadeIn extends StatelessWidget {
  const FadeIn({
    required this.child,
    this.duration = AppDurations.normal,
    this.delay = Duration.zero,
    super.key,
  });

  final Widget child;
  final Duration duration;
  final Duration delay;

  @override
  Widget build(BuildContext context) =>
      AppEntrance(duration: duration, delay: delay, child: child);
}

/// Fades and gently grows [child] in.
class ScaleIn extends StatelessWidget {
  const ScaleIn({
    required this.child,
    this.duration = AppDurations.normal,
    this.delay = Duration.zero,
    this.from = 0.92,
    super.key,
  });

  final Widget child;
  final Duration duration;
  final Duration delay;
  final double from;

  @override
  Widget build(BuildContext context) => AppEntrance(
        duration: duration,
        delay: delay,
        fromScale: from,
        curve: AppCurves.pop,
        child: child,
      );
}

/// Fades and slides [child] in from an offset (defaults to rising up).
class SlideIn extends StatelessWidget {
  const SlideIn({
    required this.child,
    this.duration = AppDurations.normal,
    this.delay = Duration.zero,
    this.from = const Offset(0, 24),
    super.key,
  });

  final Widget child;
  final Duration duration;
  final Duration delay;
  final Offset from;

  @override
  Widget build(BuildContext context) =>
      AppEntrance(duration: duration, delay: delay, fromOffset: from, child: child);
}
