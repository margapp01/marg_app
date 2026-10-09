import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import '../../core/extensions/context_extensions.dart';
import '../components/app_card.dart';
import '../dividers/app_divider.dart';

/// A titled card of settings rows ([SettingsTile]s), separated by hairlines
/// inset past the icon chip — the one way settings screens group their rows.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({
    required this.children,
    this.title,
    this.dividerIndent = iconIndent,
    this.padding = rowsPadding,
    super.key,
  });

  final String? title;
  final List<Widget> children;

  /// Card padding — [rowsPadding] for list rows; pass e.g. `AppSpacing.allMd`
  /// for a section of chips, tiles or a slider.
  final EdgeInsetsGeometry padding;
  static const EdgeInsetsGeometry rowsPadding = EdgeInsets.symmetric(vertical: AppSpacing.xs);

  /// Where each hairline starts; [iconIndent] lines it up with the row text.
  final double dividerIndent;

  /// Tile gutter + icon chip + gap.
  static const double iconIndent = AppSpacing.lg + 36 + AppSpacing.lg;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.xs, 0, AppSpacing.xs, AppSpacing.sm),
            child: Text(
              title!.toUpperCase(),
              style: context.overline.copyWith(color: context.colors.textSecondary, letterSpacing: 1.2),
            ),
          ),
        AppCard(
          padding: padding,
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) AppDivider(indent: dividerIndent, endIndent: 0),
                children[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}
