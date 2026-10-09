import 'package:flutter/material.dart';

import '../../app/theme/app_durations.dart';
import '../../app/theme/app_icons.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/extensions/context_extensions.dart';
import '../components/app_card.dart';

/// A tappable card that reflects selection with an animated primary ring and a
/// check badge — pick-one/pick-many lists (choose a route, a language, …).
class SelectableCard extends StatelessWidget {
  const SelectableCard({
    required this.selected,
    required this.onChanged,
    required this.child,
    this.enabled = true,
    super.key,
  });

  final bool selected;
  final ValueChanged<bool> onChanged;
  final Widget child;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: AppCard(
        variant: AppCardVariant.outlined,
        selected: selected,
        onTap: enabled ? () => onChanged(!selected) : null,
        child: Row(
          children: [
            Expanded(child: child),
            const SizedBox(width: AppSpacing.md),
            AnimatedSwitcher(
              duration: AppDurations.fast,
              transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
              child: selected
                  ? Icon(
                      AppIcons.success,
                      key: const ValueKey(true),
                      color: context.scheme.primary,
                    )
                  : Icon(
                      AppIcons.unchecked,
                      key: const ValueKey(false),
                      color: context.colors.border,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
