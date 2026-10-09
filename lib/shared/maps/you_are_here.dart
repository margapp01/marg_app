import 'package:flutter/material.dart';

import '../../core/extensions/context_extensions.dart';

/// The pilgrim's position on a map: a navy dot ringed in white inside a soft
/// halo.
class YouAreHereDot extends StatelessWidget {
  const YouAreHereDot({super.key});

  /// Marker box size.
  static const double size = 28;

  @override
  Widget build(BuildContext context) {
    final navy = context.scheme.secondary;
    return Container(
      decoration: BoxDecoration(shape: BoxShape.circle, color: navy.withValues(alpha: 0.18)),
      alignment: Alignment.center,
      child: Container(
        width: size * 0.55,
        height: size * 0.55,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: navy,
          border: Border.all(color: context.colors.card, width: 2.5),
        ),
      ),
    );
  }
}
