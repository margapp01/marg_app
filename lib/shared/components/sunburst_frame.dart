import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../app/theme/app_palette.dart';
import '../../core/extensions/context_extensions.dart';

/// A gilt sunburst medallion (weathered stone when [locked]) with a round
/// window in the middle holding [child] — the frame of achievement medals.
/// [rim] colours the window's border (e.g. rarity); [glow] adds a soft halo in
/// that colour.
class SunburstFrame extends StatelessWidget {
  const SunburstFrame({
    required this.size,
    required this.child,
    this.rim,
    this.window,
    this.locked = false,
    this.glow = true,
    super.key,
  });

  /// Outer diameter, ray tips included.
  final double size;
  final Widget child;
  final Color? rim;

  /// Fill behind [child] (defaults to night blue, cream when locked).
  final Color? window;
  final bool locked;
  final bool glow;

  /// Window diameter as a fraction of [size].
  static const double windowFactor = 0.7;

  @override
  Widget build(BuildContext context) {
    final disc = size * windowFactor;
    final border = locked ? context.colors.templeStone : (rim ?? context.colors.gold);
    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (glow && !locked)
            Container(
              width: disc,
              height: disc,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: border.withValues(alpha: 0.5), blurRadius: size * 0.3)],
              ),
            ),
          CustomPaint(
            size: Size.square(size),
            painter: _SunburstPainter(gradient: locked ? AppGradients.stone : AppGradients.gilt),
          ),
          Container(
            width: disc,
            height: disc,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: window ?? (locked ? context.palette.heroCream : context.palette.night),
              border: Border.all(color: border, width: math.max(1.5, size * 0.035)),
            ),
            child: ClipOval(child: child),
          ),
        ],
      ),
    );
  }
}

class _SunburstPainter extends CustomPainter {
  const _SunburstPainter({required this.gradient});

  final Gradient gradient;

  static const int _rays = 18;
  static const double _valley = 0.84;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final outer = size.shortestSide / 2;
    final path = Path();
    for (var i = 0; i < _rays * 2; i++) {
      final r = i.isEven ? outer : outer * _valley;
      final a = -math.pi / 2 + i * math.pi / _rays;
      final pt = c + Offset(math.cos(a) * r, math.sin(a) * r);
      i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
    }
    path.close();
    final shader = gradient.createShader(Offset.zero & size);
    canvas.drawPath(path, Paint()..shader = shader);
    canvas.drawCircle(
      c,
      outer * (_valley - 0.04),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(0.8, outer * 0.025)
        ..shader = shader,
    );
  }

  @override
  bool shouldRepaint(_SunburstPainter old) => old.gradient != gradient;
}
