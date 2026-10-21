import 'package:flutter/material.dart';

import '../../app/theme/theme.dart';
import '../../core/extensions/context_extensions.dart';
import '../components/app_network_image.dart';

/// A temple on a map: its photo in a coloured ring with a pointed tail.
/// Place it with `Marker(alignment: Alignment.topCenter, width: PhotoPin.widthFor(size), height: PhotoPin.heightFor(size))`
/// so the tail's tip sits on the coordinate. Without [tail] it is a round
/// marker centred on the coordinate (`Marker(width: size, height: size)`) —
/// for stops joined by route lines, which then run into the photo's centre.
class PhotoPin extends StatelessWidget {
  const PhotoPin({this.imageUrl, this.color, this.size = defaultSize, this.selected = false, this.badge, this.tail = true, super.key});

  final String? imageUrl;

  /// Ring + tail colour (defaults to saffron).
  final Color? color;
  final double size;

  /// Lifted with a glow, for the pin the user picked.
  final bool selected;

  /// A short tag in a ring-coloured disc on the photo's upper right — e.g. a
  /// route stop's number.
  final String? badge;

  final bool tail;

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
    final photo = Container(
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
    );
    final tag = badge;
    return Column(
      children: [
        if (tag == null)
          photo
        else
          Stack(
            clipBehavior: Clip.none,
            children: [
              photo,
              Positioned(
                top: -size * 0.08,
                right: -size * 0.12,
                child: Container(
                  constraints: BoxConstraints(minWidth: size * 0.42, minHeight: size * 0.42),
                  padding: EdgeInsets.symmetric(horizontal: size * 0.06),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: ring,
                    borderRadius: AppRadius.fullAll,
                    border: Border.all(color: context.colors.card, width: 2),
                    boxShadow: AppShadows.sm,
                  ),
                  child: Text(tag, style: context.textTheme.labelMedium?.bold.withColor(context.colors.card)),
                ),
              ),
            ],
          ),
        if (tail) CustomPaint(size: Size(size * 0.25, size * 0.22), painter: _PinTail(ring)),
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
