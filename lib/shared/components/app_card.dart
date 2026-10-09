import 'package:flutter/material.dart';

import '../../app/theme/app_radius.dart';
import '../../app/theme/app_shadows.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/extensions/context_extensions.dart';

/// Visual treatment of an [AppCard].
enum AppCardVariant {
  /// White surface with a soft shadow — the default content card.
  elevated,

  /// White surface with a hairline border, no shadow — dense lists.
  outlined,

  /// Tinted surface, no shadow — grouping within a page.
  filled,
}

/// The base content card: themed surface + uniform padding, optional tap with
/// ripple, and a [selected] state that draws a primary ring. Every card in the
/// system builds on this (info, stat, profile, temple, selectable …).
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.onTap,
    this.padding = AppSpacing.allLg,
    this.variant = AppCardVariant.elevated,
    this.selected = false,
    this.borderRadius = AppRadius.lgAll,
    this.clip = true,
    this.gradient,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final AppCardVariant variant;
  final bool selected;
  final BorderRadius borderRadius;
  final bool clip;

  /// Optional fill gradient (e.g. [AppGradients.peach]); overrides the
  /// variant's flat colour while keeping its shadow/border.
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final borderColor = selected
        ? context.scheme.primary
        : (variant == AppCardVariant.outlined ? colors.border : null);
    final decoration = BoxDecoration(
      color: gradient != null
          ? null
          : variant == AppCardVariant.filled
              ? context.scheme.surfaceContainerHighest
              : colors.card,
      gradient: gradient,
      borderRadius: borderRadius,
      boxShadow: variant == AppCardVariant.elevated ? AppShadows.sm : AppShadows.none,
      border: borderColor == null
          ? null
          : Border.all(color: borderColor, width: selected ? 1.6 : 1),
    );
    final content = Padding(padding: padding, child: child);
    return DecoratedBox(
      decoration: decoration,
      child: Material(
        type: MaterialType.transparency,
        child: onTap == null
            ? content
            : InkWell(
                onTap: onTap,
                borderRadius: borderRadius,
                child: content,
              ),
      ),
    );
  }
}
