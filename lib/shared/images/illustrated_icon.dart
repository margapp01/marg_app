import 'package:flutter/material.dart';

/// An illustration slot with a graceful fallback. Renders the bundled artwork
/// at [asset] when present; until the artwork is added (see
/// `docs/ASSET_REQUESTS.md`) it shows [fallbackIcon] tinted in [color] on a
/// soft disc — so missing art never breaks a screen.
class IllustratedIcon extends StatelessWidget {
  const IllustratedIcon({
    required this.fallbackIcon,
    required this.color,
    this.asset,
    this.size = 44,
    this.background,
    this.iconScale = 0.5,
    super.key,
  });

  final String? asset;
  final IconData fallbackIcon;
  final Color color;
  final double size;

  /// Disc colour behind the fallback icon (defaults to a light tint of [color]).
  final Color? background;

  /// Fallback icon size as a fraction of [size].
  final double iconScale;

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: background ?? color.withValues(alpha: 0.14), shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Icon(fallbackIcon, color: color, size: size * iconScale, fill: 1),
    );
    final path = asset;
    if (path == null) return fallback;
    return Image.asset(path, width: size, height: size, fit: BoxFit.contain, errorBuilder: (_, _, _) => fallback);
  }
}
