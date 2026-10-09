import 'package:flutter/material.dart';

import '../../app/localization/app_localizations.dart';
import '../../app/theme/theme.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/utils/formatters.dart';

/// "● Open · till 9 PM" / "● Closed · opens 5 AM" from a temple's live open
/// status (backend `openStatus`). Renders nothing when [isOpen] is unknown.
class OpenStatusLabel extends StatelessWidget {
  const OpenStatusLabel({
    required this.isOpen,
    this.opensAt,
    this.closesAt,
    super.key,
  });

  final bool? isOpen;

  /// Today's opening / closing time ("HH:mm", IST).
  final String? opensAt;
  final String? closesAt;

  @override
  Widget build(BuildContext context) {
    final open = isOpen;
    if (open == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final color = open ? context.palette.accentGreen : context.palette.crowdHigh;
    final label = open
        ? (closesAt != null ? l10n.templeOpenUntil(formatClock(closesAt!)) : l10n.templeOpenNow)
        : (opensAt != null ? l10n.templeClosedOpensAt(formatClock(opensAt!)) : l10n.templeClosedNow);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: AppSpacing.sm - 1,
          height: AppSpacing.sm - 1,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const Gap.h(AppSpacing.xs),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.labelSmall?.semiBold.withColor(color),
          ),
        ),
      ],
    );
  }
}
