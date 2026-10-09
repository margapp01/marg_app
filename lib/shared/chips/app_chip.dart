import 'package:flutter/material.dart';

import '../../app/theme/app_curves.dart';
import '../../app/theme/app_durations.dart';
import '../../app/theme/app_icons.dart';
import '../../core/extensions/context_extensions.dart';

/// Multi-select toggle chip (filters). Themed via the shared `chipTheme`.
class AppFilterChip extends StatelessWidget {
  const AppFilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    this.icon,
    super.key,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    // With an icon, the icon itself turns into the check when selected —
    // Material's own checkmark would sit on a dark scrim over the avatar.
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      avatar: icon == null
          ? null
          : Icon(selected ? AppIcons.check : icon, size: 18, color: selected ? context.scheme.primary : null),
      showCheckmark: icon == null,
    );
  }
}

/// Single-select chip within a group (choose one).
class AppChoiceChip extends StatelessWidget {
  const AppChoiceChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    this.icon,
    super.key,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      avatar: icon == null ? null : Icon(icon, size: 18),
    );
  }
}

/// A filter chip that gives a subtle scale pop when toggled — for prominent
/// filter rows where selection should feel responsive.
class AnimatedChip extends StatelessWidget {
  const AnimatedChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    this.icon,
    super.key,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: selected ? 1.05 : 1,
      duration: AppDurations.fast,
      curve: AppCurves.pop,
      child: AppFilterChip(
        label: label,
        selected: selected,
        onSelected: onSelected,
        icon: icon,
      ),
    );
  }
}
