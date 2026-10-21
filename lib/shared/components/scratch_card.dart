import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/theme.dart';

/// Scratch-to-reveal: [cover] sits over [child] until the devotee rubs away
/// [revealAt] of it with a finger, then fades out and [onRevealed] fires once.
/// Screen readers get a button that reveals it in one action.
///
/// [child] sizes the card; [cover] fills it. With [enabled] false the cover
/// can't be scratched (e.g. a reward still locked).
class ScratchCard extends StatefulWidget {
  const ScratchCard({
    required this.child,
    required this.cover,
    required this.semanticLabel,
    this.onRevealed,
    this.revealed = false,
    this.enabled = true,
    this.revealAt = 0.45,
    this.brushRadius = 22,
    super.key,
  });

  final Widget child;
  final Widget cover;
  final String semanticLabel;
  final VoidCallback? onRevealed;

  /// Already scratched (e.g. remembered from an earlier visit): no cover.
  final bool revealed;
  final bool enabled;

  /// Share of the card (0–1) to scratch before the rest falls away.
  final double revealAt;
  final double brushRadius;

  @override
  State<ScratchCard> createState() => _ScratchCardState();
}

class _ScratchCardState extends State<ScratchCard> {
  // Coverage is tracked on a coarse grid — cheap, and close enough.
  static const int _cols = 12;
  static const int _rows = 8;

  final List<Offset?> _points = []; // null breaks the stroke
  final Set<int> _cells = {};
  int _version = 0;
  late bool _revealed = widget.revealed;

  @override
  void didUpdateWidget(ScratchCard old) {
    super.didUpdateWidget(old);
    if (widget.revealed && !_revealed) setState(() => _revealed = true);
  }

  void _scratch(Offset p, Size size) {
    if (_revealed) return;
    final cw = size.width / _cols, ch = size.height / _rows;
    final r2 = widget.brushRadius * widget.brushRadius;
    for (var row = 0; row < _rows; row++) {
      for (var col = 0; col < _cols; col++) {
        final centre = Offset((col + 0.5) * cw, (row + 0.5) * ch);
        if ((centre - p).distanceSquared <= r2 * 1.5) _cells.add(row * _cols + col);
      }
    }
    setState(() {
      _points.add(p);
      _version++;
    });
    if (_cells.length / (_cols * _rows) >= widget.revealAt) _reveal();
  }

  void _reveal() {
    if (_revealed) return;
    HapticFeedback.mediumImpact();
    setState(() => _revealed = true);
    widget.onRevealed?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.revealed) return widget.child;
    return Semantics(
      button: !_revealed && widget.enabled,
      label: _revealed ? null : widget.semanticLabel,
      // Until revealed, read only the label — never the prize underneath.
      excludeSemantics: !_revealed,
      onTap: !_revealed && widget.enabled ? _reveal : null,
      child: Stack(
        children: [
          widget.child,
          Positioned.fill(
            child: IgnorePointer(
              ignoring: _revealed,
              child: AnimatedOpacity(
                opacity: _revealed ? 0 : 1,
                duration: AppDurations.slow,
                curve: AppCurves.emphasize,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final size = constraints.biggest;
                    return GestureDetector(
                      onPanStart: widget.enabled ? (d) => _scratch(d.localPosition, size) : null,
                      onPanUpdate: widget.enabled ? (d) => _scratch(d.localPosition, size) : null,
                      onPanEnd: widget.enabled ? (_) => _points.add(null) : null,
                      // The mask paints the cover into its own layer, so the
                      // eraser clears only the cover, never the prize below.
                      child: ShaderMask(
                        blendMode: BlendMode.dstIn,
                        shaderCallback: (bounds) =>
                            const LinearGradient(colors: [Colors.white, Colors.white]).createShader(bounds),
                        child: CustomPaint(
                          foregroundPainter: _EraserPainter(_points, widget.brushRadius, _version),
                          child: SizedBox.expand(child: widget.cover),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EraserPainter extends CustomPainter {
  _EraserPainter(this.points, this.radius, this.version);

  final List<Offset?> points;
  final double radius;
  final int version;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..blendMode = BlendMode.clear
      ..strokeWidth = radius * 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final path = Path();
    var drawing = false;
    for (final p in points) {
      if (p == null) {
        drawing = false;
      } else if (!drawing) {
        path
          ..moveTo(p.dx, p.dy)
          ..lineTo(p.dx, p.dy);
        drawing = true;
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_EraserPainter old) => old.version != version;
}
