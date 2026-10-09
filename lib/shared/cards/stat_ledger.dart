import 'package:flutter/material.dart';

import '../../app/theme/theme.dart';
import '../../core/extensions/context_extensions.dart';
import '../animations/animated_count.dart';
import '../badges/app_badge.dart';
import '../images/illustrated_icon.dart';
import 'parchment_card.dart';

/// One headline number in a [StatLedger].
class LedgerStat {
  const LedgerStat({required this.icon, required this.color, required this.value, required this.label, this.suffix = ''});

  final IconData icon;
  final Color color;
  final int value;
  final String label;

  /// Unit after the number (e.g. "%").
  final String suffix;
}

/// A screen's numbers at a glance as one parchment ledger: up to four
/// headline counts (illustrated icon, animated number in the display face,
/// label) divided by gold rules, with an optional [footer] row under a gold
/// hairline — Passport overview, Journey Timeline, Routes, Temples.
class StatLedger extends StatelessWidget {
  const StatLedger({required this.stats, this.footer, super.key});

  final List<LedgerStat> stats;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return ParchmentCard(
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (i, stat) in stats.indexed) ...[
                  if (i > 0) const GoldRule(vertical: true),
                  Expanded(child: _Cell(stat: stat)),
                ],
              ],
            ),
          ),
          if (footer != null) ...[
            const Gap(AppSpacing.lg),
            const GoldRule(),
            const Gap(AppSpacing.md),
            footer!,
          ],
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.stat});
  final LedgerStat stat;

  static const double _iconSize = 40;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${stat.label} ${stat.value}${stat.suffix}',
      excludeSemantics: true,
      child: Column(
        children: [
          IllustratedIcon(fallbackIcon: stat.icon, color: stat.color, size: _iconSize),
          const Gap(AppSpacing.sm),
          AnimatedCount(
            value: stat.value,
            suffix: stat.suffix,
            style: context.displayText.headlineSmall.withColor(context.scheme.secondary),
          ),
          Text(
            stat.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.caption.copyWith(color: context.colors.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// A gold hairline that fades out at both ends.
class GoldRule extends StatelessWidget {
  const GoldRule({this.vertical = false, super.key});

  final bool vertical;

  @override
  Widget build(BuildContext context) {
    final gold = context.colors.gold;
    return Container(
      width: vertical ? 1 : null,
      height: vertical ? null : 1,
      margin: vertical ? const EdgeInsets.symmetric(horizontal: AppSpacing.xs) : null,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: vertical ? Alignment.topCenter : Alignment.centerLeft,
          end: vertical ? Alignment.bottomCenter : Alignment.centerRight,
          colors: [gold.withValues(alpha: 0), gold.withValues(alpha: 0.6), gold.withValues(alpha: 0)],
        ),
      ),
    );
  }
}

/// A section label on a gold hairline — "OCTOBER 2026 ——— 4" over a month
/// of the journey timeline, "EARNED ——— 1" over certificates.
class GoldRuleHeader extends StatelessWidget {
  const GoldRuleHeader({required this.label, this.count, super.key});

  final String label;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Row(
        children: [
          Text(label.toUpperCase(), style: context.overline.copyWith(color: context.colors.gold, letterSpacing: 1.4)),
          const Gap.h(AppSpacing.sm),
          const Expanded(child: GoldRule()),
          if (count != null) ...[
            const Gap.h(AppSpacing.sm),
            AppBadge(label: '$count', tone: AppBadgeTone.neutral),
          ],
        ],
      ),
    );
  }
}
