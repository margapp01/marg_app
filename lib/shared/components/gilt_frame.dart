import 'package:flutter/widgets.dart';

import '../../app/theme/app_palette.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_shadows.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/extensions/context_extensions.dart';

/// The burnished-gold frame of MARG's collectibles (Sacred Cards, achievement
/// showcases): a gold-leaf border (weathered stone when [locked]), an inner
/// filigree hairline with corner brackets, and a glow in the [accent] colour.
///
/// With an [aspectRatio] the frame fills that shape; without one it wraps
/// [child]'s own height.
class GiltFrame extends StatelessWidget {
  const GiltFrame({
    required this.accent,
    required this.child,
    this.locked = false,
    this.large = false,
    this.aspectRatio,
    super.key,
  });

  final Color accent;
  final Widget child;
  final bool locked;

  /// Showcase scale (thicker leaf, longer brackets, stronger glow).
  final bool large;
  final double? aspectRatio;

  @override
  Widget build(BuildContext context) {
    final border = large ? AppSpacing.xs + 2 : AppSpacing.xxs + 1;
    final radius = large ? AppRadius.lg : AppRadius.md;
    final filigree = locked ? context.colors.templeStone : Color.lerp(context.colors.gold, context.colors.card, 0.35)!;
    final frame = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: locked ? AppGradients.stone : AppGradients.gilt,
        boxShadow: locked
            ? AppShadows.sm
            : [
                BoxShadow(
                  color: accent.withValues(alpha: large ? 0.45 : 0.3),
                  blurRadius: large ? 32 : 12,
                  spreadRadius: large ? 2 : 0,
                ),
              ],
      ),
      child: Padding(
        padding: EdgeInsets.all(border),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius - border / 2),
          child: Stack(
            // Pass the frame's constraints straight through so [child] fills
            // the window (full width in a list, the 3:4 box for a card).
            fit: StackFit.passthrough,
            children: [
              child,
              Positioned.fill(
                child: IgnorePointer(child: CustomPaint(painter: _FiligreePainter(color: filigree, large: large))),
              ),
            ],
          ),
        ),
      ),
    );
    return aspectRatio == null ? frame : AspectRatio(aspectRatio: aspectRatio!, child: frame);
  }
}

class _FiligreePainter extends CustomPainter {
  const _FiligreePainter({required this.color, required this.large});

  final Color color;
  final bool large;

  @override
  void paint(Canvas canvas, Size size) {
    final inset = large ? AppSpacing.sm : AppSpacing.xs;
    final reach = large ? AppSpacing.xl : AppSpacing.md;
    final gem = large ? 3.5 : 2.0;

    canvas.drawRRect(
      RRect.fromRectAndRadius((Offset.zero & size).deflate(inset), Radius.circular(inset)),
      Paint()
        ..color = color.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = large ? 1.2 : 0.8,
    );

    final bracket = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = large ? 2.2 : 1.4
      ..strokeCap = StrokeCap.round;
    final fill = Paint()..color = color;
    final d = inset + (large ? AppSpacing.xs : AppSpacing.xxs);
    final corners = [
      (d, d, 1.0, 1.0),
      (size.width - d, d, -1.0, 1.0),
      (d, size.height - d, 1.0, -1.0),
      (size.width - d, size.height - d, -1.0, -1.0),
    ];
    for (final (x, y, dx, dy) in corners) {
      canvas.drawPath(
        Path()
          ..moveTo(x, y + dy * reach)
          ..lineTo(x, y)
          ..lineTo(x + dx * reach, y),
        bracket,
      );
      final gx = x + dx * gem * 2.4;
      final gy = y + dy * gem * 2.4;
      canvas.drawPath(
        Path()
          ..moveTo(gx, gy - gem)
          ..lineTo(gx + gem, gy)
          ..lineTo(gx, gy + gem)
          ..lineTo(gx - gem, gy)
          ..close(),
        fill,
      );
    }
  }

  @override
  bool shouldRepaint(_FiligreePainter old) => old.color != color || old.large != large;
}
