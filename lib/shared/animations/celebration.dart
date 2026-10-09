import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme/app_curves.dart';

/// Celebration motion for MARG's reward moments (a card unlocked, a visit
/// verified, an achievement earned). Every piece is self-contained, cheap
/// (one controller, painted — no packages) and still when the device asks for
/// reduced motion: the final frame shows, nothing loops.

bool _still(BuildContext context) => MediaQuery.of(context).disableAnimations;

/// Twinkling four-point stars scattered over the area — the gold dust around a
/// revealed card or a medal. With [burst] they first fly out from the centre.
class SparkleField extends StatefulWidget {
  const SparkleField({required this.color, this.count = 18, this.burst = false, this.seed = 3, super.key});

  final Color color;
  final int count;

  /// Stars fly outward from the centre once before settling into a twinkle.
  final bool burst;
  final int seed;

  @override
  State<SparkleField> createState() => _SparkleFieldState();
}

class _SparkleFieldState extends State<SparkleField> with TickerProviderStateMixin {
  static const Duration _twinkle = Duration(milliseconds: 2600);
  static const Duration _burstDuration = Duration(milliseconds: 900);

  late final AnimationController _loop = AnimationController(vsync: this, duration: _twinkle);
  late final AnimationController _burst = AnimationController(vsync: this, duration: _burstDuration);
  late final List<_Star> _stars;

  @override
  void initState() {
    super.initState();
    final rng = math.Random(widget.seed);
    _stars = List.generate(
      widget.count,
      (_) => _Star(x: rng.nextDouble(), y: rng.nextDouble(), size: 3 + rng.nextDouble() * 6, phase: rng.nextDouble()),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_still(context)) {
      _loop.stop();
      _burst.value = 1;
    } else {
      if (!_loop.isAnimating) _loop.repeat();
      if (widget.burst && _burst.value == 0) _burst.forward();
    }
  }

  @override
  void dispose() {
    _loop.dispose();
    _burst.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: Listenable.merge([_loop, _burst]),
          builder: (context, _) => CustomPaint(
            size: Size.infinite,
            painter: _SparklePainter(
              stars: _stars,
              t: _loop.value,
              spread: widget.burst ? AppCurves.enter.transform(_burst.value) : 1,
              color: widget.color,
            ),
          ),
        ),
      ),
    );
  }
}

class _Star {
  const _Star({required this.x, required this.y, required this.size, required this.phase});
  final double x;
  final double y;
  final double size;
  final double phase;
}

class _SparklePainter extends CustomPainter {
  _SparklePainter({required this.stars, required this.t, required this.spread, required this.color});

  final List<_Star> stars;
  final double t;
  final double spread;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final centre = size.center(Offset.zero);
    for (final s in stars) {
      final home = Offset(s.x * size.width, s.y * size.height);
      final at = Offset.lerp(centre, home, spread)!;
      // Each star breathes on its own phase: 0.25 → 1 → 0.25.
      final wave = 0.5 + 0.5 * math.sin((t + s.phase) * math.pi * 2);
      final r = s.size * (0.55 + 0.45 * wave);
      paint.color = color.withValues(alpha: (0.25 + 0.75 * wave) * spread.clamp(0, 1));
      canvas.drawPath(_star(at, r), paint);
    }
  }

  /// A slim four-point twinkle.
  static Path _star(Offset c, double r) {
    final w = r * 0.28;
    return Path()
      ..moveTo(c.dx, c.dy - r)
      ..quadraticBezierTo(c.dx + w, c.dy - w, c.dx + r, c.dy)
      ..quadraticBezierTo(c.dx + w, c.dy + w, c.dx, c.dy + r)
      ..quadraticBezierTo(c.dx - w, c.dy + w, c.dx - r, c.dy)
      ..quadraticBezierTo(c.dx - w, c.dy - w, c.dx, c.dy - r)
      ..close();
  }

  @override
  bool shouldRepaint(_SparklePainter old) => old.t != t || old.spread != spread || old.color != color;
}

/// A soft radial glow that slowly breathes behind [child] — the aura of a
/// card, seal or medal.
class GlowPulse extends StatefulWidget {
  const GlowPulse({required this.color, required this.child, this.radius = 140, super.key});

  final Color color;
  final Widget child;

  /// Radius of the glow at full breath, in logical px.
  final double radius;

  @override
  State<GlowPulse> createState() => _GlowPulseState();
}

class _GlowPulseState extends State<GlowPulse> with SingleTickerProviderStateMixin {
  static const Duration _breath = Duration(milliseconds: 2200);
  late final AnimationController _controller = AnimationController(vsync: this, duration: _breath, value: 1);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_still(context)) {
      _controller.value = 1;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true, min: 0.6);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        IgnorePointer(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final r = widget.radius * (0.85 + 0.15 * _controller.value);
              return Container(
                width: r * 2,
                height: r * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      widget.color.withValues(alpha: 0.55 * _controller.value),
                      widget.color.withValues(alpha: 0),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        widget.child,
      ],
    );
  }
}

/// Keeps [child] gently floating up and down — a revealed card at rest.
class FloatBob extends StatefulWidget {
  const FloatBob({required this.child, this.amplitude = 6, super.key});

  final Widget child;
  final double amplitude;

  @override
  State<FloatBob> createState() => _FloatBobState();
}

class _FloatBobState extends State<FloatBob> with SingleTickerProviderStateMixin {
  static const Duration _period = Duration(milliseconds: 3200);
  late final AnimationController _controller = AnimationController(vsync: this, duration: _period);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_still(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, widget.amplitude * (AppCurves.emphasize.transform(_controller.value) * 2 - 1)),
        child: child,
      ),
      child: widget.child,
    );
  }
}

/// A band of light that sweeps diagonally across [child] every few seconds —
/// the sheen on a freshly minted card.
class LightSweep extends StatefulWidget {
  const LightSweep({required this.child, this.borderRadius = BorderRadius.zero, super.key});

  final Widget child;
  final BorderRadius borderRadius;

  @override
  State<LightSweep> createState() => _LightSweepState();
}

class _LightSweepState extends State<LightSweep> with SingleTickerProviderStateMixin {
  static const Duration _cycle = Duration(milliseconds: 3600);

  /// Share of the cycle the sweep is moving; the rest it rests off-card.
  static const double _moving = 0.35;
  late final AnimationController _controller = AnimationController(vsync: this, duration: _cycle);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_still(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: ClipRRect(
              borderRadius: widget.borderRadius,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  final p = (_controller.value / _moving).clamp(0.0, 1.0);
                  if (p == 0 || p == 1) return const SizedBox.shrink();
                  final x = -1.5 + 3 * AppCurves.emphasize.transform(p);
                  return DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(x - 0.6, -1),
                        end: Alignment(x + 0.6, 1),
                        colors: [
                          Colors.white.withValues(alpha: 0),
                          Colors.white.withValues(alpha: 0.32),
                          Colors.white.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// [child] lands like a rubber stamp: dropped from above, oversized and
/// tilted, then pressed flat — a passport stamp being struck.
class StampSlam extends StatelessWidget {
  const StampSlam({required this.child, this.delay = Duration.zero, this.angle = -0.12, super.key});

  final Widget child;
  final Duration delay;

  /// Resting tilt, in radians.
  final double angle;

  static const Duration _duration = Duration(milliseconds: 520);

  @override
  Widget build(BuildContext context) {
    if (_still(context)) return Transform.rotate(angle: angle, child: child);
    return _Delayed(
      delay: delay,
      builder: (started) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: started ? 1 : 0),
        duration: _duration,
        curve: Curves.easeInCubic,
        builder: (context, t, child) => Opacity(
          opacity: t.clamp(0, 1),
          child: Transform.rotate(
            angle: angle - 0.35 * (1 - t),
            child: Transform.scale(scale: 1 + 0.9 * (1 - t), child: child),
          ),
        ),
        child: child,
      ),
    );
  }
}

/// Shakes [child] side to side once as it appears — a refusal.
class ShakeIn extends StatelessWidget {
  const ShakeIn({required this.child, this.delay = Duration.zero, super.key});

  final Widget child;
  final Duration delay;

  static const Duration _duration = Duration(milliseconds: 650);
  static const double _reach = 10;
  static const int _shakes = 3;

  @override
  Widget build(BuildContext context) {
    if (_still(context)) return child;
    return _Delayed(
      delay: delay,
      builder: (started) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: started ? 1 : 0),
        duration: _duration,
        builder: (context, t, child) => Transform.translate(
          offset: Offset(math.sin(t * math.pi * 2 * _shakes) * _reach * (1 - t), 0),
          child: child,
        ),
        child: child,
      ),
    );
  }
}

/// A check mark that draws itself inside a filled disc that pops in, with a
/// ripple ring — "Visit Verified".
class DrawnCheckSeal extends StatelessWidget {
  const DrawnCheckSeal({required this.color, this.size = 96, super.key});

  final Color color;

  /// The disc's diameter; the widget is [boxFactor] × wider for the ripple.
  final double size;

  static const double boxFactor = 1.6;
  static const Duration _duration = Duration(milliseconds: 1100);

  @override
  Widget build(BuildContext context) {
    final still = _still(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: still ? 1 : 0, end: 1),
      duration: _duration,
      builder: (context, t, _) => CustomPaint(
        size: Size.square(size * boxFactor),
        painter: _CheckSealPainter(t: t, color: color, radius: size / 2),
      ),
    );
  }
}

class _CheckSealPainter extends CustomPainter {
  _CheckSealPainter({required this.t, required this.color, required this.radius});

  final double t;
  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    // 0 → 0.45: the disc pops (overshoot); 0.35 → 0.85: the tick draws;
    // 0.4 → 1: a ring ripples out and fades.
    final pop = AppCurves.pop.transform((t / 0.45).clamp(0, 1));
    final draw = Curves.easeOut.transform(((t - 0.35) / 0.5).clamp(0, 1));
    final ripple = ((t - 0.4) / 0.6).clamp(0.0, 1.0);

    if (ripple > 0) {
      canvas.drawCircle(
        c,
        radius * (1 + 0.55 * ripple),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = color.withValues(alpha: 0.5 * (1 - ripple)),
      );
    }
    canvas.drawCircle(c, radius * pop, Paint()..color = color);

    if (draw > 0) {
      final tick = Path()
        ..moveTo(c.dx - radius * 0.42, c.dy + radius * 0.02)
        ..lineTo(c.dx - radius * 0.1, c.dy + radius * 0.34)
        ..lineTo(c.dx + radius * 0.46, c.dy - radius * 0.3);
      final metric = tick.computeMetrics().first;
      canvas.drawPath(
        metric.extractPath(0, metric.length * draw),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = radius * 0.16
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = Colors.white,
      );
    }
  }

  @override
  bool shouldRepaint(_CheckSealPainter old) => old.t != t || old.color != color;
}

/// Starts the animation in [builder] after [delay] (immediately when zero).
class _Delayed extends StatefulWidget {
  const _Delayed({required this.delay, required this.builder});

  final Duration delay;
  final Widget Function(bool started) builder;

  @override
  State<_Delayed> createState() => _DelayedState();
}

class _DelayedState extends State<_Delayed> {
  late bool _started = widget.delay == Duration.zero;

  @override
  void initState() {
    super.initState();
    if (!_started) {
      Future<void>.delayed(widget.delay, () {
        if (mounted) setState(() => _started = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) => widget.builder(_started);
}
