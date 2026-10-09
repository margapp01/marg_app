import 'package:flutter/material.dart';

import '../../app/theme/app_curves.dart';
import '../../app/theme/app_durations.dart';
import '../../app/theme/app_icons.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/extensions/context_extensions.dart';

/// A header that expands/collapses [child] with a smooth height + fade and a
/// rotating chevron. Reusable for FAQs, filters, grouped settings, details.
class ExpandableSection extends StatefulWidget {
  const ExpandableSection({
    required this.title,
    required this.child,
    this.leading,
    this.initiallyExpanded = false,
    this.padding = AppSpacing.allLg,
    super.key,
  });

  final Widget title;
  final Widget child;
  final Widget? leading;
  final bool initiallyExpanded;
  final EdgeInsetsGeometry padding;

  @override
  State<ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<ExpandableSection> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: widget.padding,
            child: Row(
              children: [
                if (widget.leading != null) ...[
                  widget.leading!,
                  const SizedBox(width: AppSpacing.md),
                ],
                Expanded(
                  child: DefaultTextStyle.merge(
                    style: context.textTheme.titleSmall!,
                    child: widget.title,
                  ),
                ),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: AppDurations.fast,
                  child: Icon(AppIcons.expandMore, color: context.colors.textSecondary),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: AppDurations.normal,
          curve: AppCurves.standard,
          alignment: Alignment.topCenter,
          child: AnimatedSwitcher(
            duration: AppDurations.fast,
            child: _expanded
                ? Padding(
                    padding: widget.padding.subtract(
                      const EdgeInsets.only(top: AppSpacing.lg),
                    ),
                    child: widget.child,
                  )
                : const SizedBox(width: double.infinity),
          ),
        ),
      ],
    );
  }
}
