import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/router/app_shell.dart';
import '../../../../app/router/route_names.dart';
import '../../../../shared/design_system.dart';
import '../../../notifications/presentation/controllers/notification_controllers.dart';
import '../../domain/entities/passport.dart';
import '../controllers/passport_controllers.dart';
import '../widgets/passport_widgets.dart';

/// Spiritual Passport — the pilgrim's digital identity: hero passport card,
/// journey overview, and entries into timeline / map / collection / routes /
/// temples / statistics / certificates / share.
class PassportDashboardPage extends ConsumerWidget {
  const PassportDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(passportDashboardProvider);

    final header = TabHeader(
      title: l10n.ppTitle,
      onMenu: AppShell.openMenu,
      onNotifications: () => context.pushNamed(RouteNames.notifications),
      notificationCount: ref.watch(unreadBadgeProvider),
      trailing: IconButton(
        icon: Icon(AppIcons.share, color: context.scheme.secondary),
        tooltip: l10n.ppShare,
        onPressed: () => context.pushNamed(RouteNames.passportShare),
      ),
    );
    return Scaffold(
      backgroundColor: context.scheme.surface,
      body: Column(
        children: [
          header,
          Expanded(child: _body(context, ref, l10n, async)),
        ],
      ),
    );
  }

  Widget _body(BuildContext context, WidgetRef ref, AppLocalizations l10n, AsyncValue<PassportBundle> async) {
    return async.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(
          title: l10n.ppErrorTitle,
          message: l10n.ppErrorBody,
          onRetry: () => ref.invalidate(passportDashboardProvider),
        ),
        data: (bundle) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(passportDashboardProvider),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.huge),
            children: [
              RepaintBoundary(
                child: PassportHeroCard(
                  overview: bundle.overview,
                  rank: bundle.rank,
                  qrData: 'MARG Passport · ${bundle.overview.passportId}',
                ),
              ),
              const Gap(AppSpacing.lg),
              SectionHeader(title: l10n.ppJourneyOverview),
              const Gap(AppSpacing.sm),
              _Overview(bundle: bundle),
              const Gap(AppSpacing.lg),
              SectionHeader(title: l10n.ppExplore),
              const Gap(AppSpacing.sm),
              _NavTiles(),
            ],
          ),
        ),
    );
  }
}

/// The journey at a glance as one parchment ledger: three headline counts
/// under gold rules, then the smaller tallies (cards, referrals, rank).
class _Overview extends StatelessWidget {
  const _Overview({required this.bundle});
  final PassportBundle bundle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.palette;
    final s = bundle.overview.statistics;
    final headline = [
      (AppIcons.temple, p.accentSaffron, s.totalVisitedTemples, l10n.ppTemplesVisited),
      (AppIcons.verified, p.accentGreen, s.verifiedVisits, l10n.ppVerifiedVisits),
      (AppIcons.route, p.accentBlue, s.routesCompleted, l10n.ppRoutesCompleted),
    ];
    final tallies = [
      (AppIcons.card, p.accentAmber, '${s.cardsCollected}', l10n.ppCards),
      if (bundle.referral != null)
        (AppIcons.referral, p.accentViolet, '${bundle.referral!.successfulInvites}', l10n.ppReferrals),
      if (bundle.rank?.globalRank != null)
        (AppIcons.leaderboard, p.accentRose, '#${bundle.rank!.globalRank}', l10n.ppGlobalRank),
    ];
    return StatLedger(
      stats: [
        for (final (icon, color, value, label) in headline) LedgerStat(icon: icon, color: color, value: value, label: label),
      ],
      footer: Row(
        children: [
          for (final (icon, color, value, label) in tallies)
            Expanded(child: _Tally(icon: icon, color: color, value: value, label: label)),
        ],
      ),
    );
  }
}

class _Tally extends StatelessWidget {
  const _Tally({required this.icon, required this.color, required this.value, required this.label});
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label $value',
      excludeSemantics: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: color, fill: 1),
          const Gap.h(AppSpacing.xs),
          Flexible(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: value, style: context.textTheme.titleSmall?.bold.withColor(context.scheme.secondary)),
                  TextSpan(text: ' $label', style: context.caption.copyWith(color: context.colors.textSecondary)),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// The passport's sections as tinted tiles, two per row on phones.
class _NavTiles extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.palette;
    final tiles = <(IconData, String, String, String, Color)>[
      (AppIcons.history, l10n.ppTimeline, l10n.ppTimelineHint, RouteNames.passportTimeline, p.accentSaffron),
      (AppIcons.map, l10n.ppMap, l10n.ppMapHint, RouteNames.passportMap, p.accentGreen),
      (AppIcons.card, l10n.ppCollection, l10n.ppCollectionHint, RouteNames.passportCollection, p.accentRose),
      (AppIcons.route, l10n.ppRoutes, l10n.ppRoutesHint, RouteNames.passportRoutes, p.accentBlue),
      (AppIcons.temple, l10n.ppTemples, l10n.ppTemplesHint, RouteNames.passportTemples, p.accentAmber),
      (AppIcons.trending, l10n.ppStatistics, l10n.ppStatisticsHint, RouteNames.passportStatistics, p.accentViolet),
      (AppIcons.description, l10n.ppCertificates, l10n.ppCertificatesHint, RouteNames.passportCertificates, p.accentSaffron),
      (AppIcons.qrScan, l10n.ppPublicPassport, l10n.ppPublicPassportHint, RouteNames.passportPublic, p.accentTeal),
    ];
    return GridView.count(
      crossAxisCount: context.responsive(compact: 2, medium: 4),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.45,
      children: [
        for (final (i, (icon, title, hint, route, accent)) in tiles.indexed)
          AccentTile(
            icon: icon,
            title: title,
            subtitle: hint,
            accent: accent,
            onTap: () => context.pushNamed(route),
          ).fadeIn(delay: AppDurations.stagger * i),
      ],
    );
  }
}
