import 'package:flutter/material.dart';

import '../../app/theme/theme.dart';
import '../../core/extensions/context_extensions.dart';

/// A row of five stars. Read-only when [onChanged] is null (fractional
/// [value]s round to the nearest half); otherwise a tappable 1–5 picker with
/// ≥48dp targets.
class StarRating extends StatelessWidget {
  const StarRating({required this.value, this.size = 16, this.onChanged, this.semanticsLabel, super.key});

  final double value;
  final double size;
  final ValueChanged<int>? onChanged;

  /// Read-only semantics (e.g. "4.5 stars").
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final amber = context.palette.accentAmber;
    final empty = context.colors.border;
    final rounded = (value * 2).round() / 2;

    Widget star(int i) {
      final fill = rounded >= i ? 1.0 : (rounded >= i - 0.5 ? 0.5 : 0.0);
      final icon = fill == 0.5 ? AppIcons.starHalf : AppIcons.star;
      final glyph = Icon(icon, size: size, color: fill > 0 ? amber : empty, fill: fill > 0 ? 1 : 0);
      if (onChanged == null) return glyph;
      return Semantics(
        button: true,
        selected: value.round() == i,
        label: '$i',
        child: InkResponse(
          onTap: () => onChanged!(i),
          radius: size,
          child: Padding(padding: const EdgeInsets.all(AppSpacing.xs), child: glyph),
        ),
      );
    }

    final row = Row(mainAxisSize: MainAxisSize.min, children: [for (var i = 1; i <= 5; i++) star(i)]);
    return onChanged == null && semanticsLabel != null
        ? Semantics(label: semanticsLabel, child: ExcludeSemantics(child: row))
        : row;
  }
}
