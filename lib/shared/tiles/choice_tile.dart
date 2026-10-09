import 'package:flutter/material.dart';

import '../../app/theme/theme.dart';
import '../../core/extensions/context_extensions.dart';
import '../images/illustrated_icon.dart';

/// Selected-state styling shared by the choice tiles: a soft saffron wash,
/// saffron border and a check badge in the corner.
BoxDecoration _choiceDecoration(BuildContext context, bool selected) => BoxDecoration(
      color: selected ? context.scheme.primary.withValues(alpha: 0.08) : context.colors.card,
      borderRadius: AppRadius.mdAll,
      border: Border.all(
        color: selected ? context.scheme.primary : context.colors.border,
        width: selected ? 1.5 : 1,
      ),
      boxShadow: selected ? null : AppShadows.xs,
    );

/// A compact selectable tile — an icon (or illustrated art) over a label and
/// optional subtitle, with a check badge when [selected] — gender, deities,
/// visit frequency, language (onboarding + Spiritual Preferences).
class ChoiceTile extends StatelessWidget {
  const ChoiceTile({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.asset,
    this.accent,
    this.subtitle,
    super.key,
  });

  final String label;
  final String? subtitle;
  final IconData? icon;

  /// Illustrated art shown instead of [icon] when it loads.
  final String? asset;
  final Color? accent;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = accent ?? context.scheme.primary;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.mdAll,
          child: AnimatedContainer(
            duration: AppDurations.fast,
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.md),
            decoration: _choiceDecoration(context, selected),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        IllustratedIcon(
                          asset: asset,
                          fallbackIcon: icon!,
                          color: selected ? context.scheme.primary : color,
                          size: 32,
                          iconScale: 0.85,
                        ),
                        const Gap(AppSpacing.xs),
                      ],
                      Text(
                        label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.labelMedium?.semiBold.withColor(context.scheme.secondary),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.labelSmall?.copyWith(color: context.colors.textSecondary),
                        ),
                    ],
                  ),
                ),
                Positioned(top: -AppSpacing.sm, right: -AppSpacing.xxs, child: _CheckBadge(visible: selected)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// [ChoiceTile]s in [columns] equal-width columns. Each row is as tall as its
/// tallest tile — no fixed aspect ratio, so a two-line label, the selected
/// border or large text never clips.
class ChoiceGrid extends StatelessWidget {
  const ChoiceGrid({required this.columns, required this.children, super.key});

  final int columns;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var start = 0; start < children.length; start += columns) ...[
          if (start > 0) const Gap(AppSpacing.sm),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < columns; i++) ...[
                  if (i > 0) const Gap.h(AppSpacing.sm),
                  Expanded(child: start + i < children.length ? children[start + i] : const SizedBox.shrink()),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// A full-width selectable row — tinted icon, title + optional subtitle and a
/// square checkbox (or, with [radio], a round single-choice dot) — e.g.
/// onboarding's "What brings you here?", sort orders and date ranges in
/// filter sheets.
class OptionCard extends StatelessWidget {
  const OptionCard({
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
    this.subtitle,
    this.accent,
    this.radio = false,
    this.trailing,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? accent;
  final bool selected;
  final VoidCallback onTap;

  /// One-of-many choice: a round indicator instead of a checkbox.
  final bool radio;

  /// Extra affordance before the indicator (e.g. a calendar for "Custom").
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final color = accent ?? context.scheme.primary;
    return Semantics(
      button: true,
      selected: selected,
      label: title,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.mdAll,
          child: AnimatedContainer(
            duration: AppDurations.fast,
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: subtitle == null ? AppSpacing.sm : AppSpacing.md,
            ),
            decoration: _choiceDecoration(context, selected),
            child: Row(
              children: [
                IllustratedIcon(
                  fallbackIcon: icon,
                  color: color,
                  background: color.withValues(alpha: 0.12),
                  size: subtitle == null ? 36 : 44,
                ),
                const Gap.h(AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: context.textTheme.titleSmall?.semiBold.withColor(context.scheme.secondary)),
                      if (subtitle != null) ...[
                        const Gap(AppSpacing.xxs),
                        Text(
                          subtitle!,
                          style: context.textTheme.bodySmall?.copyWith(color: context.colors.textSecondary),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[const Gap.h(AppSpacing.sm), trailing!],
                const Gap.h(AppSpacing.sm),
                AnimatedContainer(
                  duration: AppDurations.fast,
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: selected ? context.scheme.primary : Colors.transparent,
                    shape: radio ? BoxShape.circle : BoxShape.rectangle,
                    borderRadius: radio ? null : AppRadius.xsAll,
                    border: Border.all(color: selected ? context.scheme.primary : context.colors.border, width: 1.5),
                  ),
                  child: selected ? Icon(AppIcons.check, size: 16, color: context.scheme.onPrimary) : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckBadge extends StatelessWidget {
  const _CheckBadge({required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: visible ? 1 : 0,
      duration: AppDurations.fast,
      curve: AppCurves.standard,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: context.scheme.primary,
          shape: BoxShape.circle,
          border: Border.all(color: context.colors.card, width: 1.5),
        ),
        child: Icon(AppIcons.check, size: 12, color: context.scheme.onPrimary),
      ),
    );
  }
}
