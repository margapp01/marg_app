import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/passport.dart';
import '../../domain/entities/passport_share.dart';
import '../../domain/entities/timeline_event.dart';

/// The flagship passport identity block: the shared [PilgrimHero], the gilt
/// progress card and the ID strip (member since, passport id, QR).
class PassportHeroCard extends StatelessWidget {
  const PassportHeroCard({required this.overview, this.rank, this.qrData, super.key});

  final PassportOverview overview;
  final PassportRank? rank;
  final String? qrData;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PilgrimHero(
          imageUrl: overview.profilePhoto,
          name: overview.name,
          level: rank == null ? null : '${l10n.ppLevel} · ${tierLabel(l10n, rank!.tier)}',
        ),
        const Gap(AppSpacing.lg),
        PassportProgressCard(overview: overview, rank: rank).fadeIn(delay: 80.ms),
        const Gap(AppSpacing.md),
        PassportIdCard(overview: overview, qrData: qrData).fadeIn(delay: 140.ms),
      ],
    );
  }
}

/// Completion ring, tier, trust score and next-level progress on a night sky
/// inside the gilt frame.
class PassportProgressCard extends StatelessWidget {
  const PassportProgressCard({required this.overview, this.rank, this.label, super.key});

  final PassportOverview overview;
  final PassportRank? rank;

  /// Heading above the tier (defaults to "Passport Completion").
  final String? label;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final gold = context.colors.gold;
    final light = context.colors.card;
    final dim = light.withValues(alpha: 0.7);
    final track = light.withValues(alpha: 0.12);
    final r = rank;
    return GiltFrame(
      accent: gold,
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.night),
        child: Padding(
          padding: AppSpacing.allLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AppCircularProgress(
                    value: (overview.passportCompletion / 100).clamp(0, 1),
                    size: 92,
                    strokeWidth: 8,
                    color: gold,
                    backgroundColor: track,
                    center: Text('${overview.passportCompletion}%', style: context.textTheme.titleLarge?.bold.withColor(light)),
                  ),
                  const Gap.h(AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label ?? l10n.ppCompletion, style: context.textTheme.labelMedium?.withColor(dim)),
                        if (r != null)
                          Text(tierLabel(l10n, r.tier), style: context.displayText.titleLarge.copyWith(color: gold)),
                        const Gap(AppSpacing.xs),
                        Text(l10n.ppTrustScore, style: context.caption.copyWith(color: dim)),
                        Row(
                          children: [
                            AnimatedCount(value: overview.trustScore, style: context.displayText.headlineSmall.copyWith(color: light)),
                            if (r?.rising ?? false) ...[
                              const Gap.h(AppSpacing.sm),
                              Icon(AppIcons.star, size: 14, color: gold, fill: 1),
                              const Gap.h(AppSpacing.xxs),
                              Flexible(
                                child: Text(l10n.ppRisingStar, style: context.caption.copyWith(color: gold), overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (r?.nextTier != null) ...[
                const Gap(AppSpacing.lg),
                AppLinearProgress(value: r!.tierProgress, height: 6, color: gold, backgroundColor: track),
                const Gap(AppSpacing.xs),
                Row(
                  children: [
                    Expanded(
                      child: Text('${l10n.ppNextLevel}: ${tierLabel(l10n, r.nextTier!)}', style: context.caption.copyWith(color: dim)),
                    ),
                    Text('${r.points} / ${r.points + (r.pointsToNextTier ?? 0)}', style: context.caption.copyWith(color: dim)),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Member since · passport id · QR.
class PassportIdCard extends StatelessWidget {
  const PassportIdCard({required this.overview, this.qrData, super.key});

  final PassportOverview overview;
  final String? qrData;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.palette;
    return AppCard(
      padding: AppSpacing.allMd,
      child: Row(
        children: [
          Expanded(child: _idColumn(context, AppIcons.calendar, p.accentSaffron, l10n.ppMemberSince, _date(overview.memberSince))),
          Container(
            width: 1,
            height: _iconSize,
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            color: context.colors.divider,
          ),
          Expanded(child: _idColumn(context, AppIcons.passport, p.accentViolet, l10n.ppPassportId, overview.passportId)),
          if (qrData != null) ...[
            const Gap.h(AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: context.colors.card,
                borderRadius: AppRadius.smAll,
                border: Border.all(color: context.colors.gold.withValues(alpha: 0.6)),
              ),
              child: QrImageView(data: qrData!, size: 56, padding: EdgeInsets.zero),
            ),
          ],
        ],
      ),
    );
  }

  static const double _iconSize = 36;

  Widget _idColumn(BuildContext context, IconData icon, Color color, String label, String value) => Row(
        children: [
          IllustratedIcon(fallbackIcon: icon, color: color, size: _iconSize),
          const Gap.h(AppSpacing.sm),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: context.caption.copyWith(color: context.colors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(value, style: context.textTheme.bodySmall?.semiBold.withColor(context.scheme.secondary), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      );

  static String _date(DateTime? d) {
    if (d == null) return '—';
    const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  }
}

/// Temples · Cards · Routes completion, each with an illustrated icon and a
/// progress bar, under the overall percentage — shared by Passport Statistics
/// and Profile → My Statistics.
class PassportCompletionCard extends StatelessWidget {
  const PassportCompletionCard({required this.overview, super.key});

  final PassportOverview overview;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.palette;
    return AppCard(
      padding: AppSpacing.allLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.ppCompletionBreakdown,
                  style: context.textTheme.titleSmall?.semiBold.withColor(context.scheme.secondary),
                ),
              ),
              AppBadge(label: '${overview.passportCompletion}%', tone: AppBadgeTone.primary),
            ],
          ),
          const Gap(AppSpacing.lg),
          _row(context, AppIcons.temple, p.accentSaffron, l10n.ppTemples, overview.templesPercent),
          const Gap(AppSpacing.md),
          _row(context, AppIcons.card, p.accentBlue, l10n.ppCards, overview.cardsPercent),
          const Gap(AppSpacing.md),
          _row(context, AppIcons.route, p.accentAmber, l10n.ppRoutes, overview.routesPercent),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, IconData icon, Color color, String label, int percent) => Row(
        children: [
          IllustratedIcon(fallbackIcon: icon, color: color, size: 36),
          const Gap.h(AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(label, style: context.textTheme.bodyMedium?.medium)),
                    Text('$percent%', style: context.textTheme.bodyMedium?.semiBold.withColor(color)),
                  ],
                ),
                const Gap(AppSpacing.xs),
                AppLinearProgress(value: (percent / 100).clamp(0, 1), color: color, height: 6),
              ],
            ),
          ),
        ],
      );
}

/// The shareable / public passport card: a self-contained premium summary
/// (avatar, name, trust, completion, headline counts, optional QR). Rendered
/// into a PNG for sharing and shown as-is on the public preview.
class PassportShareCard extends StatelessWidget {
  const PassportShareCard({required this.share, this.qrData, super.key});

  final PassportShare share;
  final String? qrData;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final gold = context.colors.gold;
    return Container(
      padding: AppSpacing.allLg,
      decoration: BoxDecoration(
        color: context.colors.splashCanvas,
        borderRadius: AppRadius.xlAll,
        border: Border.all(color: gold, width: 2),
        boxShadow: [BoxShadow(color: gold.withValues(alpha: 0.22), blurRadius: 20, spreadRadius: 1)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.ppSpiritualPassport, style: context.overline.copyWith(color: gold, letterSpacing: 1.5)),
          const Gap(AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(shape: BoxShape.circle, gradient: SweepGradient(colors: [gold, context.scheme.primary, gold])),
            child: CircleAvatar(
              radius: 40,
              backgroundColor: context.scheme.surface,
              foregroundImage: share.profilePhoto == null ? null : NetworkImage(share.profilePhoto!),
              child: share.profilePhoto == null ? Icon(AppIcons.profile, size: 36, color: context.colors.textSecondary) : null,
            ),
          ),
          const Gap(AppSpacing.sm),
          Text(share.name, style: context.brandText.headlineSmall, textAlign: TextAlign.center),
          const Gap(AppSpacing.lg),
          Row(
            children: [
              Expanded(child: _stat(context, '${share.passportCompletion}%', l10n.ppCompletion)),
              _sep(context),
              Expanded(child: _stat(context, '${share.trustScore}', l10n.ppTrustScore)),
            ],
          ),
          const Gap(AppSpacing.md),
          Row(
            children: [
              Expanded(child: _stat(context, '${share.visitedTemples}', l10n.ppTemples)),
              _sep(context),
              Expanded(child: _stat(context, '${share.cardsCollected}', l10n.ppCards)),
              _sep(context),
              Expanded(child: _stat(context, '${share.routesCompleted}', l10n.ppRoutes)),
            ],
          ),
          if (qrData != null) ...[
            const Gap(AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(color: Colors.white, borderRadius: AppRadius.mdAll),
              child: QrImageView(data: qrData!, size: 96, padding: EdgeInsets.zero),
            ),
          ],
        ],
      ),
    );
  }

  Widget _stat(BuildContext context, String v, String label) => Column(
        children: [
          Text(v, style: context.textTheme.titleLarge?.bold.copyWith(color: context.colors.gold)),
          Text(label, style: context.caption.copyWith(color: context.colors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      );

  Widget _sep(BuildContext context) => Container(width: 1, height: 34, color: context.colors.divider);
}

/// A journey-overview stat tile.
class PassportStatTile extends StatelessWidget {
  const PassportStatTile({required this.icon, required this.value, required this.label, this.color, super.key});

  final IconData icon;
  final String value;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? context.scheme.primary;
    return AppCard(
      padding: AppSpacing.allMd,
      child: Row(
        children: [
          IllustratedIcon(fallbackIcon: icon, color: c, size: 42),
          const Gap.h(AppSpacing.md),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: context.caption.copyWith(color: context.colors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.textTheme.titleLarge?.bold.withColor(context.scheme.secondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Colour + icon for a journey event type (timeline nodes, filter chips).
(IconData, Color) timelineStyle(BuildContext context, TimelineEventType type) {
  final p = context.palette;
  return switch (type) {
    TimelineEventType.visit => (AppIcons.temple, p.accentSaffron),
    TimelineEventType.route => (AppIcons.route, p.accentBlue),
    TimelineEventType.achievement => (AppIcons.achievement, p.accentAmber),
    TimelineEventType.card => (AppIcons.card, p.accentRose),
    TimelineEventType.milestone => (AppIcons.star, p.accentViolet),
  };
}

/// One entry in the journey timeline: the shared [JourneyRailTile] in the
/// event's colour, with its photo, place, date and any points.
class TimelineEventTile extends StatelessWidget {
  const TimelineEventTile({required this.event, required this.isLast, this.onTap, super.key});

  final TimelineEvent event;

  /// Last in its month — the rail stops at the node.
  final bool isLast;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = timelineStyle(context, event.type);
    return JourneyRailTile(
      icon: icon,
      color: color,
      title: event.title,
      subtitle: event.subtitle,
      caption: DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag()).format(event.date),
      captionIcon: AppIcons.calendar,
      imageUrl: event.imageUrl,
      isLast: isLast,
      onTap: onTap,
      trailing: event.points != null
          ? AppBadge(label: '+${event.points}', icon: AppIcons.points, tone: AppBadgeTone.gold)
          : onTap != null
              ? Icon(AppIcons.chevronRight, color: context.colors.textDisabled)
              : null,
    );
  }
}
