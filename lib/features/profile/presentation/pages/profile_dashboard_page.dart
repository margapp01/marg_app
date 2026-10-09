import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/router/route_names.dart';
import '../../../../shared/design_system.dart';
import '../../../achievements/presentation/controllers/achievements_controllers.dart';
import '../../../notifications/presentation/controllers/notification_controllers.dart';
import '../../../passport/domain/entities/passport.dart';
import '../../../passport/presentation/controllers/passport_controllers.dart';
import '../../../passport/presentation/widgets/passport_widgets.dart';
import '../../domain/entities/profile.dart';
import '../controllers/profile_controllers.dart';
import '../widgets/profile_widgets.dart';

/// Screen 1 — the Profile Dashboard: identity hero, spiritual progress, journey
/// snapshot, quick actions and account navigation.
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
                  const _ProgressCard(),
                  const Gap(AppSpacing.lg),
                  SectionHeader(title: l10n.pfJourneySnapshot),
                  const Gap(AppSpacing.sm),
                  const _JourneySnapshot(),
                  const Gap(AppSpacing.lg),
                  _QuickActions(profile: profile),
                  const Gap(AppSpacing.lg),
                  _AccountNav(),
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
              NotificationBell(
                count: ref.watch(unreadBadgeProvider),
                onTap: () => context.pushNamed(RouteNames.notifications),
              ),
              IconButton(
                icon: Icon(AppIcons.settings, color: context.scheme.secondary),
                tooltip: l10n.pfAppPreferences,
                onPressed: () => context.pushNamed(RouteNames.profileAppPreferences),
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

/// The passport's gilt progress card + ID strip; a skeleton of the same
/// footprint while the passport loads, nothing if it fails (the Passport tab
/// owns that error state).
class _ProgressCard extends ConsumerWidget {
  const _ProgressCard();

  static const double _skeletonHeight = 236;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return ref.watch(passportDashboardProvider).when(
          loading: () => const SkeletonBox(height: _skeletonHeight, radius: AppRadius.card),
          error: (_, _) => const SizedBox.shrink(),
          data: (bundle) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PassportProgressCard(overview: bundle.overview, rank: bundle.rank, label: l10n.pfSpiritualProgress),
              const Gap(AppSpacing.md),
              PassportIdCard(overview: bundle.overview),
            ],
          ).fadeIn(),
        );
  }
}

class _JourneySnapshot extends ConsumerWidget {
  const _JourneySnapshot();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final bundle = ref.watch(passportDashboardProvider).valueOrNull;
    final s = bundle?.overview.statistics ?? PassportStatistics.empty;
    final referral = bundle?.referral;
    final achievements = ref.watch(achievementCollectionProvider.select((a) => a.valueOrNull?.earnedCount ?? 0));
    return Column(
      children: [
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.sm,
          crossAxisSpacing: AppSpacing.sm,
          childAspectRatio: ProfileStatTile.aspect,
          children: [
            ProfileStatTile(icon: AppIcons.temple, value: '${s.totalVisitedTemples}', label: l10n.pfVisits),
            ProfileStatTile(
              icon: AppIcons.card,
              value: '${s.cardsCollected}',
              label: l10n.pfCards,
              color: context.colors.info,
            ),
            ProfileStatTile(
              icon: AppIcons.achievement,
              value: '$achievements',
              label: l10n.pfAchievements,
              color: context.palette.accentViolet,
            ),
            ProfileStatTile(
              icon: AppIcons.route,
              value: '${s.routesCompleted}',
              label: l10n.pfRoutes,
              color: context.colors.gold,
            ),
          ],
        ),
        const Gap(AppSpacing.sm),
        AppCard(
          onTap: () => context.pushNamed(RouteNames.referrals),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          child: Row(
            children: [
              IllustratedIcon(fallbackIcon: AppIcons.referral, color: context.palette.accentSaffron, size: 40),
              const Gap.h(AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.pfReferralPoints, style: context.caption.copyWith(color: context.colors.textSecondary)),
                    AnimatedCount(value: referral?.pointsEarned ?? 0, style: context.textTheme.titleLarge!.bold.withColor(context.scheme.secondary)),
                  ],
                ),
              ),
              Icon(AppIcons.chevronRight, color: context.colors.textSecondary),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.profile});
  final Profile profile;

  @override
  Widget build(BuildContext context) {
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
          AppIcons.passport,
          l10n.pfPassport,
          p.tileLavender,
          p.accentViolet,
          () => context.goNamed(RouteNames.passport),
        ),
        _action(
          context,
          AppIcons.settings,
          l10n.pfPreferences,
          p.tileSky,
          p.accentBlue,
          () => context.pushNamed(RouteNames.profileAppPreferences),
        ),
        _action(context, AppIcons.share, l10n.pfShare, p.tileMint, p.accentGreen, () => _share(profile, l10n)),
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

  void _share(Profile profile, AppLocalizations l10n) {
    SharePlus.instance.share(ShareParams(text: '${profile.name ?? l10n.pfPilgrim} · ${l10n.pfShareText}'));
  }
}

class _AccountNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsGroup(
          title: l10n.pfGroupAccount,
          children: [
            SettingsTile.navigation(
              icon: AppIcons.temple,
              iconColor: p.accentSaffron,
              title: l10n.pfSpiritualPreferences,
              onTap: () => context.pushNamed(RouteNames.profilePreferences),
            ),
            SettingsTile.navigation(
              icon: AppIcons.trending,
              iconColor: p.accentBlue,
              title: l10n.pfMyStatistics,
              onTap: () => context.pushNamed(RouteNames.profileStatistics),
            ),
            SettingsTile.navigation(
              icon: AppIcons.smartphone,
              iconColor: p.accentTeal,
              title: l10n.pfMyDevices,
              onTap: () => context.pushNamed(RouteNames.profileDevices),
            ),
            SettingsTile.navigation(
              icon: AppIcons.shield,
              iconColor: p.accentGreen,
              title: l10n.pfPrivacySecurity,
              onTap: () => context.pushNamed(RouteNames.profilePrivacy),
            ),
          ],
        ),
        const Gap(AppSpacing.lg),
        SettingsGroup(
          title: l10n.pfGroupApp,
          children: [
            SettingsTile.navigation(
              icon: AppIcons.settings,
              iconColor: p.accentViolet,
              title: l10n.pfAppPreferences,
              onTap: () => context.pushNamed(RouteNames.profileAppPreferences),
            ),
            SettingsTile.navigation(
              icon: AppIcons.help,
              iconColor: p.accentRose,
              title: l10n.pfHelpSupport,
              onTap: () => context.pushNamed(RouteNames.profileHelp),
            ),
          ],
        ),
      ],
    );
  }
}
