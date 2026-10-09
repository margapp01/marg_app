import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme/app_icons.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/extensions/context_extensions.dart';

/// A hairline horizontal rule in the divider colour, with optional [indent]
/// (mirrored at the end unless [endIndent] is given).
class AppDivider extends StatelessWidget {
  const AppDivider({this.indent = 0, this.endIndent, this.height = 1, super.key});

  final double indent;
  final double? endIndent;
  final double height;

  @override
  Widget build(BuildContext context) => Divider(
        height: height,
        thickness: 1,
        indent: indent,
        endIndent: endIndent ?? indent,
        color: context.colors.divider,
      );
}

/// A hairline vertical rule — separates inline items (e.g. stat columns).
class AppVerticalDivider extends StatelessWidget {
  const AppVerticalDivider({this.width = 1, super.key});

  final double width;

  @override
  Widget build(BuildContext context) => VerticalDivider(
        width: width,
        thickness: 1,
        color: context.colors.divider,
      );
}

/// A section separator with generous vertical breathing room.
class SectionDivider extends StatelessWidget {
  const SectionDivider({super.key});

  @override
  Widget build(BuildContext context) => Divider(
        height: AppSpacing.xxl,
        thickness: 1,
        color: context.colors.divider,
      );
}

/// A divider with a centred label ( ──── or ──── ), e.g. "OR" between actions.
class LabelDivider extends StatelessWidget {
  const LabelDivider({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final line = Expanded(
      child: Divider(color: context.colors.divider, thickness: 1),
    );
    return Row(
      children: [
        line,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            label,
            style: context.textTheme.labelMedium
                ?.copyWith(color: context.colors.textSecondary),
          ),
        ),
        line,
      ],
    );
  }
}

/// Ornamental rule ( ◆──── 🪷 ────◆ ) set under ceremonial titles — the empty
/// state scenes and celebration screens.
class LotusRule extends StatelessWidget {
  const LotusRule({this.width = 160, super.key});

  final double width;

  @override
  Widget build(BuildContext context) {
    final color = context.scheme.primary;
    Widget arm({required bool leading}) => Expanded(
          child: Row(
            children: [
              if (leading) _Dot(color: color),
              Expanded(child: Container(height: 1, color: color.withValues(alpha: 0.7))),
              if (!leading) _Dot(color: color),
            ],
          ),
        );
    return ExcludeSemantics(
      child: SizedBox(
        width: width,
        child: Row(
          children: [
            arm(leading: true),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Icon(AppIcons.lotus, size: 20, color: color),
            ),
            arm(leading: false),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Transform.rotate(
        angle: math.pi / 4,
        child: Container(width: AppSpacing.xs, height: AppSpacing.xs, color: color),
      );
}
