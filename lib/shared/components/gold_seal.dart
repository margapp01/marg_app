import 'package:flutter/material.dart';

import '../../app/theme/theme.dart';
import '../../core/extensions/context_extensions.dart';

/// A round gold-to-saffron seal with a white emblem — the stamp on a route
/// certificate and, with [glow], the completion medal.
class GoldSeal extends StatelessWidget {
  const GoldSeal({this.icon = AppIcons.verified, this.size = 64, this.glow = false, super.key});

  final IconData icon;
  final double size;

  /// A soft gold halo, for the celebratory medal.
  final bool glow;

  @override
  Widget build(BuildContext context) {
    final gold = context.colors.gold;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [gold, context.scheme.primary]),
        border: Border.all(color: Color.lerp(gold, Colors.white, 0.5)!, width: size * 0.03),
        boxShadow: glow
            ? [BoxShadow(color: gold.withValues(alpha: 0.5), blurRadius: 30, spreadRadius: 2)]
            : [BoxShadow(color: gold.withValues(alpha: 0.35), blurRadius: 10)],
      ),
      child: Icon(icon, size: size * 0.46, color: Colors.white, fill: 1),
    );
  }
}
