import 'package:flutter/material.dart';

import '../../app/theme/theme.dart';
import '../../core/extensions/context_extensions.dart';
import 'app_avatar.dart';

/// The pilgrim's avatar in a gold-to-saffron sweep ring with a soft glow and
/// a cream gap — the Profile / Passport hero and Edit Profile.
class GoldRingAvatar extends StatelessWidget {
  const GoldRingAvatar({this.imageUrl, this.name, this.radius = defaultRadius, super.key});

  final String? imageUrl;
  final String? name;
  final double radius;

  static const double defaultRadius = 48;

  /// Outer diameter (ring included) for an avatar of [radius].
  static double diameterFor(double radius) => (radius + AppSpacing.xxs + AppSpacing.xs) * 2;

  @override
  Widget build(BuildContext context) {
    final gold = context.colors.gold;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: SweepGradient(colors: [gold, context.palette.accentSaffron, gold]),
        boxShadow: [BoxShadow(color: gold.withValues(alpha: 0.35), blurRadius: 28, spreadRadius: 2)],
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xxs),
        decoration: BoxDecoration(shape: BoxShape.circle, color: context.scheme.surface),
        child: AppAvatar(imageUrl: imageUrl, name: name, radius: radius),
      ),
    );
  }
}
