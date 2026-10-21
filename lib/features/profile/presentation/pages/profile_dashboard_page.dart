import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/router/route_names.dart';
import '../../../../shared/design_system.dart';
import '../../../achievements/presentation/controllers/achievements_controllers.dart';
import '../../../cards/presentation/controllers/cards_controllers.dart';
import '../../../cards/presentation/widgets/collection_showcase.dart';
import '../../../notifications/presentation/controllers/notification_controllers.dart';
import '../../../passport/domain/entities/passport.dart';
import '../../../passport/presentation/controllers/passport_controllers.dart';
import '../../../passport/presentation/widgets/passport_widgets.dart';
import '../../domain/entities/profile.dart';
import '../../domain/entities/profile_completion.dart';
import '../controllers/profile_controllers.dart';

/// The Profile tab — the devotee's identity and Spiritual Passport in one
/// place: hero, how complete the profile is (onboarding can be skipped), the
/// passport progress + ID, the Sacred Card collection, the journey ledger, the
/// passport's sections, quick actions and account settings.
class ProfileDashboardPage extends ConsumerWidget {
  const ProfileDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: context.scheme.surface,
      body: Stack(
        children: [
          _body(context, ref, l10n, profileAsync),
          // Keeps scrolled content from running under the status-bar icons.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.paddingOf(context).top,
            child: ColoredBox(color: Color.alphaBlend(_Header.sand(context), context.scheme.surface)),
          ),
        ],
      ),
    );
  }

  Widget _body(BuildContext context, WidgetRef ref, AppLocalizations l10n, AsyncValue<Profile> profileAsync) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(profileProvider);
        ref.invalidate(passportDashboardProvider);
      },
      child: profileAsync.when(
        loading: () => const LoadingView(),
        error: (_, _) => ErrorView(
          title: l10n.pfErrorTitle,
          message: l10n.pfErrorBody,
          onRetry: () => ref.invalidate(profileProvider),
        ),
        data: (profile) => ListView(
          padding: EdgeInsets.zero,
          children: [
            _Header(profile: profile),
            Padding(
              padding: AppSpacing.screenAll,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CompletionCard(completion: ProfileCompletion.of(profile)),
                  const _ProgressCard(),
                  const Gap(AppSpacing.xl),
                  SectionHeader(title: l10n.pfMySacredCards, onViewAll: () => context.goNamed(RouteNames.cards)),
                  const Gap(AppSpacing.sm),
                  const _CollectionCard(),
                  const Gap(AppSpacing.xl),
                  SectionHeader(title: l10n.ppJourneyOverview),
                  const Gap(AppSpacing.sm),
                  const _JourneySnapshot(),
                  const Gap(AppSpacing.xl),
                  SectionHeader(title: l10n.pfPassportSections),
                  const Gap(AppSpacing.sm),
                  const _PassportTiles(),
                  const Gap(AppSpacing.xl),
                  _QuickActions(profile: profile),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header({required this.profile});
  final Profile profile;

  /// The warm wash at the top of the header (also tints the status bar).
  static Color sand(BuildContext context) => context.colors.templeSand.withValues(alpha: 0.5);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tier = ref.watch(passportDashboardProvider.select((a) => a.valueOrNull?.rank?.tier));
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        MediaQuery.paddingOf(context).top + AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [sand(context), context.scheme.surface],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(l10n.pfTitle, style: context.displayText.headlineMedium),
              const Spacer(),
              IconButton(
                icon: Icon(AppIcons.share, color: context.scheme.secondary),
                tooltip: l10n.ppShare,
                onPressed: () => context.pushNamed(RouteNames.passportShare),
              ),
              NotificationBell(
                count: ref.watch(unreadBadgeProvider),
                onTap: () => context.pushNamed(RouteNames.notifications),
              ),
              IconButton(
                icon: Icon(AppIcons.settings, color: context.scheme.secondary),
                tooltip: l10n.pfPreferences,
                onPressed: () => context.pushNamed(RouteNames.profileSettings),
              ),
            ],
          ),
          PilgrimHero(
            name: profile.name ?? l10n.pfPilgrim,
            imageUrl: profile.profilePhoto,
            verified: profile.isPhoneVerified,
            level: tier == null ? null : '${l10n.pfLevel} · ${tierLabel(l10n, tier)}',
          ),
        ],
      ),
    );
  }
}

/// "Your profile is 56% complete" — what's still missing and one tap to fill
/// it in. Hidden once everything is there.
class _CompletionCard extends StatelessWidget {
  const _CompletionCard({required this.completion});

  final ProfileCompletion completion;

  static const int _shownChips = 4;

  void _complete(BuildContext context) {
    final next = completion.next;
    if (next == null) return;
    context.pushNamed(next.onPreferences ? RouteNames.profilePreferences : RouteNames.profileEdit);
  }

  @override
  Widget build(BuildContext context) {
    if (completion.isComplete) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final saffron = context.scheme.primary;
    final missing = completion.missing;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Container(
        padding: AppSpacing.allLg,
        decoration: BoxDecoration(
          gradient: AppGradients.parchment,
          borderRadius: AppRadius.card,
          border: Border.all(color: saffron.withValues(alpha: 0.35)),
          boxShadow: AppShadows.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                AppCircularProgress(
                  value: completion.percent / 100,
                  size: 64,
                  strokeWidth: 6,
                  color: saffron,
                  backgroundColor: saffron.withValues(alpha: 0.15),
                  center: Text('${completion.percent}%', style: context.textTheme.titleSmall?.bold.withColor(context.scheme.secondary)),
                ),
                const Gap.h(AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.pfCompletionTitle(completion.percent),
                        style: context.textTheme.titleMedium?.semiBold.withColor(context.scheme.secondary),
                      ),
                      const Gap(AppSpacing.xxs),
                      Text(l10n.pfCompletionBody, style: context.caption.copyWith(color: context.colors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(AppSpacing.md),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final item in missing.take(_shownChips))
                  AppBadge(label: profileItemLabel(l10n, item), icon: AppIcons.add, tone: AppBadgeTone.primary),
                if (missing.length > _shownChips) AppBadge(label: '+${missing.length - _shownChips}', tone: AppBadgeTone.neutral),
              ],
            ),
            const Gap(AppSpacing.md),
            AppButton.primary(
              label: l10n.pfCompletionCta,
              icon: AppIcons.edit,
              size: AppButtonSize.small,
              onPressed: () => _complete(context),
            ),
          ],
        ),
      ).fadeIn(),
    );
  }
}

/// Label for a missing [ProfileItem] chip.
String profileItemLabel(AppLocalizations l10n, ProfileItem item) => switch (item) {
      ProfileItem.photo => l10n.pfItemPhoto,
      ProfileItem.mobile => l10n.pfItemMobile,
      ProfileItem.birthday => l10n.pfItemBirthday,
      ProfileItem.gender => l10n.pfItemGender,
      ProfileItem.city => l10n.pfItemCity,
      ProfileItem.interests => l10n.pfItemInterests,
      ProfileItem.deities => l10n.pfItemDeities,
      ProfileItem.visitFrequency => l10n.pfItemFrequency,
      ProfileItem.yatras => l10n.pfItemYatras,
    };

/// The Spiritual Passport: the gilt progress card and the ID strip (with QR);
/// a skeleton of the same footprint while it loads, an inline retry if it fails.
class _ProgressCard extends ConsumerWidget {
  const _ProgressCard();

  static const double _skeletonHeight = 236;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return ref.watch(passportDashboardProvider).when(
          loading: () => const SkeletonBox(height: _skeletonHeight, radius: AppRadius.card),
          error: (_, _) => EmptyCard(
            icon: AppIcons.passport,
            label: l10n.ppErrorBody,
            onTap: () => ref.invalidate(passportDashboardProvider),
          ),
          data: (bundle) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RepaintBoundary(child: PassportProgressCard(overview: bundle.overview, rank: bundle.rank)),
              const Gap(AppSpacing.md),
              PassportIdCard(overview: bundle.overview, qrData: 'MARG Passport · ${bundle.overview.passportId}'),
            ],
          ).fadeIn(),
        );
  }
}

/// The Sacred Card collection in miniature; opens the Cards tab.
class _CollectionCard extends ConsumerWidget {
  const _CollectionCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(collectionStatsProvider).valueOrNull;
    if (stats == null) return const SkeletonBox(height: 150, radius: AppRadius.card);
    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: () => context.goNamed(RouteNames.cards),
        child: CollectionShowcase(
          stats: stats,
          cards: ref.watch(recentCardsProvider).valueOrNull ?? const [],
          compact: true,
        ),
      ),
    ).fadeIn();
  }
}

/// The journey at a glance as one parchment ledger: three headline counts
/// under gold rules, then the smaller tallies (cards, achievements, rank,
/// referral points).
class _JourneySnapshot extends ConsumerWidget {
  const _JourneySnapshot();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final p = context.palette;
    final bundle = ref.watch(passportDashboardProvider).valueOrNull;
    final s = bundle?.overview.statistics ?? PassportStatistics.empty;
    final achievements = ref.watch(achievementCollectionProvider.select((a) => a.valueOrNull?.earnedCount ?? 0));
    final tallies = [
      (AppIcons.achievement, p.accentViolet, '$achievements', l10n.pfAchievements, RouteNames.achievements),
      if (bundle?.rank?.globalRank != null)
        (AppIcons.leaderboard, p.accentRose, '#${bundle!.rank!.globalRank}', l10n.ppGlobalRank, RouteNames.leaderboards),
      (AppIcons.referral, p.accentSaffron, '${bundle?.referral?.pointsEarned ?? 0}', l10n.pfReferralPoints, RouteNames.referrals),
    ];
    return StatLedger(
      stats: [
        LedgerStat(icon: AppIcons.temple, color: p.accentSaffron, value: s.totalVisitedTemples, label: l10n.ppTemplesVisited),
        LedgerStat(icon: AppIcons.verified, color: p.accentGreen, value: s.verifiedVisits, label: l10n.ppVerifiedVisits),
        LedgerStat(icon: AppIcons.route, color: p.accentBlue, value: s.routesCompleted, label: l10n.ppRoutesCompleted),
      ],
      footer: Row(
        children: [
          for (final (icon, color, value, label, route) in tallies)
            Expanded(
              child: InkWell(
                onTap: () => context.pushNamed(route),
                borderRadius: AppRadius.mdAll,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: _Tally(icon: icon, color: color, value: value, label: label),
                ),
              ),
            ),
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color, fill: 1),
              const Gap.h(AppSpacing.xs),
              Text(value, style: context.textTheme.titleSmall?.bold.withColor(context.scheme.secondary)),
            ],
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.caption.copyWith(color: context.colors.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// The passport's sections as tinted tiles, two per row on phones.
class _PassportTiles extends StatelessWidget {
  const _PassportTiles();

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

class _QuickActions extends ConsumerWidget {
  const _QuickActions({required this.profile});
  final Profile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final p = context.palette;
    return Row(
      children: [
        _action(
          context,
          AppIcons.edit,
          l10n.pfEditProfile,
          p.tilePeach,
          p.accentSaffron,
          () => context.pushNamed(RouteNames.profileEdit),
        ),
        _action(
          context,
          AppIcons.referral,
          l10n.pfInvite,
          p.tileLavender,
          p.accentViolet,
          () => context.pushNamed(RouteNames.referrals),
        ),
        _action(
          context,
          AppIcons.settings,
          l10n.pfPreferences,
          p.tileSky,
          p.accentBlue,
          () => context.pushNamed(RouteNames.profileSettings),
        ),
        _action(context, AppIcons.share, l10n.pfShare, p.tileMint, p.accentGreen, () => _share(ref, profile, l10n)),
      ],
    );
  }

  Widget _action(BuildContext context, IconData icon, String label, Color tint, Color accent, VoidCallback onTap) =>
      Expanded(
        child: Semantics(
          button: true,
          label: label,
          child: InkWell(
            onTap: onTap,
            borderRadius: AppRadius.lgAll,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Column(
                children: [
                  IllustratedIcon(fallbackIcon: icon, color: accent, background: tint, size: 52),
                  const Gap(AppSpacing.xs),
                  Text(
                    label,
                    style: context.textTheme.labelSmall?.semiBold,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  void _share(WidgetRef ref, Profile profile, AppLocalizations l10n) {
    ref.read(shareServiceProvider).share(
          ShareMessage(kind: ShareKind.profile, text: ShareCopy.profile(l10n, name: profile.name ?? l10n.pfPilgrim)),
        );
  }
}
