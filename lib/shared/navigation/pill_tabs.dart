import 'package:flutter/material.dart';

import '../../app/theme/theme.dart';
import '../../core/extensions/context_extensions.dart';

/// A compact segmented selector ("This Month · All Time", "All · Unread · …").
/// The selected segment is a saffron pill; the rest are plain text.
class PillTabs extends StatelessWidget {
  const PillTabs({
    required this.labels,
    required this.selected,
    required this.onChanged,
    this.scrollable = false,
    super.key,
  });

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;

  /// Scroll horizontally instead of splitting the width evenly.
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final items = [
      for (var i = 0; i < labels.length; i++)
        _Pill(label: labels[i], selected: i == selected, onTap: () => onChanged(i), expand: !scrollable),
    ];
    final row = Row(mainAxisSize: scrollable ? MainAxisSize.min : MainAxisSize.max, children: items);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxs + 1),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: AppRadius.fullAll,
        border: Border.all(color: context.colors.divider),
      ),
      child: scrollable ? SingleChildScrollView(scrollDirection: Axis.horizontal, child: row) : row,
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.selected, required this.onTap, required this.expand});

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final pill = Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: AppDurations.fast,
          curve: AppCurves.standard,
          constraints: const BoxConstraints(minHeight: 36),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: selected ? AppGradients.primary : null,
            borderRadius: AppRadius.fullAll,
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.labelLarge?.copyWith(
              color: selected ? context.scheme.onPrimary : context.colors.textSecondary,
              fontWeight: selected ? AppTypography.semiBold : AppTypography.medium,
            ),
          ),
        ),
      ),
    );
    return expand ? Expanded(child: pill) : pill;
  }
}
