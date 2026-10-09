import 'package:flutter/material.dart';

import '../../app/theme/theme.dart';
import '../../core/extensions/context_extensions.dart';
import '../components/app_network_image.dart';

/// A temple on a map: its photo in a coloured ring with a pointed tail.
/// Place it with `Marker(alignment: Alignment.topCenter, width: PhotoPin.widthFor(size), height: PhotoPin.heightFor(size))`
/// so the tail's tip sits on the coordinate.
class PhotoPin extends StatelessWidget {
  const PhotoPin({this.imageUrl, this.color, this.size = defaultSize, this.selected = false, super.key});

  final String? imageUrl;

  /// Ring + tail colour (defaults to saffron).
  final Color? color;
  final double size;

  /// Lifted with a glow, for the pin the user picked.
  final bool selected;

  static const double defaultSize = 56;

  static double widthFor(double size) => size;
  static double heightFor(double size) => size * 1.22;

  @override
  Widget build(BuildContext context) {
    final ring = color ?? context.scheme.primary;
    final fallback = ColoredBox(
      color: context.colors.templeSand,
      child: Icon(AppIcons.temple, color: ring, size: size * 0.42),
    );
    return Column(
      children: [
        Container(
          width: size,
          height: size,
          padding: EdgeInsets.all(size * 0.055),
          decoration: BoxDecoration(
            color: ring,
            shape: BoxShape.circle,
            boxShadow: selected
                ? [BoxShadow(color: ring.withValues(alpha: 0.55), blurRadius: 16, spreadRadius: 2)]
                : AppShadows.md,
          ),
          child: ClipOval(
            child: imageUrl == null ? fallback : AppNetworkImage(url: imageUrl!, fit: BoxFit.cover, fallback: fallback),
          ),
        ),
        CustomPaint(size: Size(size * 0.25, size * 0.22), painter: _PinTail(ring)),
      ],
    );
  }
}

class _PinTail extends CustomPainter {
  const _PinTail(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_PinTail old) => old.color != color;
}
