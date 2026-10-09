import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/extensions/context_extensions.dart';

/// A lightweight, self-painted confetti burst — a single controller animating a
/// set of particles. No external package; drop it over a celebration screen
/// inside a `Stack` (e.g. `Positioned.fill`). Colours come from the theme.
class ConfettiOverlay extends StatefulWidget {
  const ConfettiOverlay({this.particleCount = 60, super.key});

  final int particleCount;

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Particle> _particles;
  final _rng = math.Random(7);
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Respect Reduce Animations: never even start the burst when disabled.
    if (!_started && !MediaQuery.of(context).disableAnimations) {
      _started = true;
      _controller.forward();
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400));
    _particles = List.generate(widget.particleCount, (_) {
      return _Particle(
        dx: _rng.nextDouble(),
        angle: (_rng.nextDouble() - 0.5) * 0.6,
        speed: 0.6 + _rng.nextDouble() * 0.6,
        size: 5 + _rng.nextDouble() * 7,
        hue: _rng.nextInt(4),
        rotations: _rng.nextDouble() * 4,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Reduce Animations → skip the celebratory burst entirely.
    if (MediaQuery.of(context).disableAnimations) return const SizedBox.shrink();
    final palette = [
      context.scheme.primary,
      context.colors.gold,
      context.colors.success,
      context.colors.info,
    ];
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          size: Size.infinite,
          painter: _ConfettiPainter(_particles, _controller.value, palette),
        ),
      ),
    );
  }
}

class _Particle {
  _Particle({
    required this.dx,
    required this.angle,
    required this.speed,
    required this.size,
    required this.hue,
    required this.rotations,
  });

  final double dx;
  final double angle;
  final double speed;
  final double size;
  final int hue;
  final double rotations;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.particles, this.t, this.palette);

  final List<_Particle> particles;
  final double t;
  final List<Color> palette;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final p in particles) {
      final progress = (t * p.speed).clamp(0.0, 1.0);
      final x = size.width * (p.dx + p.angle * progress);
      final y = size.height * (progress * 1.15) - p.size;
      final opacity = (1 - progress).clamp(0.0, 1.0);
      paint.color = palette[p.hue % palette.length].withValues(alpha: opacity);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rotations * math.pi * 2 * progress);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}
