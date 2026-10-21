import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/router/app_navigation.dart';
import '../../../../app/router/route_names.dart';
import '../../../../features/auth/presentation/controllers/auth_controller.dart';
import '../../../../features/profile/presentation/controllers/profile_controllers.dart';
import '../../../../shared/design_system.dart';
import '../controllers/home_controller.dart';

/// The app menu (Home ☰): a night-sky header with the devotee, their cards and
/// completed Yatras, then every destination in three groups on a white panel —
/// the tab the devotee is on highlighted — and the MARG mark with the app
/// version at the foot. Nothing in the app is more than two taps away.
class HomeDrawer extends ConsumerWidget {
  const HomeDrawer({this.currentTab = 0, super.key});

  /// The bottom-nav tab underneath (0 Home · 1 Explore · 2 Cards · 3 Yatra ·
  /// 4 Profile), so its row shows as current.
  final int currentTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final dashboard = ref.watch(homeControllerProvider).valueOrNull;
    final email = ref.watch(authControllerProvider.select((s) => s.user?.email));
    final unread = dashboard?.unreadNotifications ?? 0;
    final navy = context.scheme.secondary;
    final saffron = context.scheme.primary;

    // Close the drawer first, then navigate (push keeps the tab underneath).
    void open(String name) {
      Navigator.of(context).pop();
      context.openNamed(name);
    }

    _Item item(IconData icon, String label, String route, {Color? color, int? tab, int badge = 0}) => _Item(
          icon: icon,
          label: label,
          color: color ?? navy,
          selected: tab != null && tab == currentTab,
          badge: badge,
          onTap: () => open(route),
        );

    return Drawer(
      backgroundColor: navy,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(AppSpacing.xl)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(
            name: dashboard?.profile?.name,
            email: email,
            photo: dashboard?.profile?.profilePhoto,
            cards: dashboard?.passport?.cardsCollected ?? 0,
            yatras: dashboard?.passport?.routesCompleted ?? 0,
            onProfile: () => open(RouteNames.profile),
          ),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: context.colors.card,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.xl)),
              ),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.md),
                children: [
                  item(AppIcons.home, l10n.navHome, RouteNames.home, color: saffron, tab: 0),
                  item(AppIcons.search, l10n.drawerExploreTemples, RouteNames.explore, tab: 1),
                  item(AppIcons.card, l10n.drawerMyCards, RouteNames.cards, tab: 2),
                  item(AppIcons.route, l10n.drawerYatraRoutes, RouteNames.routes, color: saffron, tab: 3),
                  item(AppIcons.achievement, l10n.titleAchievements, RouteNames.achievements, color: saffron),
                  item(AppIcons.passport, l10n.titlePassport, RouteNames.passport),
                  const _Divider(),
                  item(AppIcons.blog, l10n.kbKnowledgeHub, RouteNames.knowledge),
                  item(AppIcons.festival, l10n.kbFestivals, RouteNames.knowledgeFestivals, color: saffron),
                  item(AppIcons.quote, l10n.kbDailyQuotes, RouteNames.knowledgeQuotes),
                  item(AppIcons.favorite, l10n.homeActionSaved, RouteNames.exploreSaved, color: saffron),
                  item(AppIcons.leaderboard, l10n.titleLeaderboards, RouteNames.leaderboards),
                  const _Divider(),
                  item(AppIcons.referral, l10n.homeReferralTitle, RouteNames.referrals),
                  item(AppIcons.notifications, l10n.titleNotifications, RouteNames.notifications, badge: unread),
                  item(AppIcons.settings, l10n.titleSettings, RouteNames.profileSettings),
                  item(AppIcons.help, l10n.pfHelpSupport, RouteNames.profileHelp),
                  const Gap(AppSpacing.lg),
                  _BrandFooter(onTap: () => open(RouteNames.knowledgeAbout)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Night sky with a faint temple skyline: close, the devotee (→ Profile) in a
/// gold ring, and their cards collected / Yatras completed.
class _Header extends StatelessWidget {
  const _Header({
    required this.name,
    required this.email,
    required this.photo,
    required this.cards,
    required this.yatras,
    required this.onProfile,
  });

  final String? name;
  final String? email;
  final String? photo;
  final int cards;
  final int yatras;
  final VoidCallback onProfile;

  static const double _avatarRadius = 30;
  static const double _skylineHeight = 110;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final light = context.colors.card;
    final gold = context.colors.gold;
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppGradients.night),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              BrandAssets.skylineLineArt,
              height: _skylineHeight,
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter,
              color: light.withValues(alpha: 0.1),
              colorBlendMode: BlendMode.srcIn,
              excludeFromSemantics: true,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.xs, AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: Icon(AppIcons.close, color: light),
                      tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  Semantics(
                    button: true,
                    child: InkWell(
                      onTap: onProfile,
                      borderRadius: AppRadius.mdAll,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: AppGradients.gilt,
                                boxShadow: [BoxShadow(color: gold.withValues(alpha: 0.35), blurRadius: 12)],
                              ),
                              child: AppAvatar(imageUrl: photo, name: name, radius: _avatarRadius),
                            ),
                            const Gap.h(AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name ?? l10n.homeDevotee,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: context.textTheme.titleMedium?.bold.withColor(light),
                                  ),
                                  if (email != null && email!.isNotEmpty)
                                    Text(
                                      email!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: context.caption.copyWith(color: light.withValues(alpha: 0.75)),
                                    ),
                                ],
                              ),
                            ),
                            Icon(AppIcons.chevronRight, color: light),
                            const Gap.h(AppSpacing.sm),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Gap(AppSpacing.md),
                  Divider(height: 1, color: light.withValues(alpha: 0.15)),
                  const Gap(AppSpacing.md),
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(child: _Stat(icon: AppIcons.card, color: gold, value: cards, label: l10n.ppCardsCollected)),
                        VerticalDivider(width: AppSpacing.lg, color: light.withValues(alpha: 0.15)),
                        Expanded(
                          child: _Stat(
                            icon: AppIcons.route,
                            color: context.scheme.primary,
                            value: yatras,
                            label: l10n.drawerYatrasCompleted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.color, required this.value, required this.label});

  final IconData icon;
  final Color color;
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final light = context.colors.card;
    return Row(
      children: [
        Icon(icon, color: color, size: 28),
        const Gap.h(AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedCount(value: value, style: context.textTheme.titleMedium?.bold.withColor(light)),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.caption.copyWith(color: light.withValues(alpha: 0.8)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// One menu row: icon, label, an unread [badge] when above zero, and a
/// chevron; the current tab's row sits on a soft saffron wash.
class _Item extends StatelessWidget {
  const _Item({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.selected = false,
    this.badge = 0,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool selected;
  final int badge;

  @override
  Widget build(BuildContext context) {
    final saffron = context.scheme.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: selected ? saffron.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: AppRadius.mdAll,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.mdAll,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              child: Row(
                children: [
                  Icon(icon, color: selected ? saffron : color, size: 24),
                  const Gap.h(AppSpacing.lg),
                  Expanded(
                    child: Text(
                      label,
                      style: context.textTheme.bodyLarge?.medium.withColor(selected ? saffron : context.scheme.secondary),
                    ),
                  ),
                  if (badge > 0) ...[
                    Container(
                      constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: saffron, borderRadius: AppRadius.fullAll),
                      child: Text(
                        badge > 99 ? '99+' : '$badge',
                        style: context.textTheme.labelSmall?.bold.withColor(context.colors.card),
                      ),
                    ),
                    const Gap.h(AppSpacing.xs),
                  ],
                  Icon(AppIcons.chevronRight, size: 20, color: selected ? saffron : context.colors.textSecondary),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: AppSpacing.sm),
        child: AppDivider(),
      );
}

/// The MARG logotype and the app version, on a quiet card (→ About).
class _BrandFooter extends ConsumerWidget {
  const _BrandFooter({required this.onTap});

  final VoidCallback onTap;

  static const double _logoHeight = 40;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final version = ref.watch(appVersionProvider).valueOrNull ?? '';
    return Material(
      color: context.scheme.surfaceContainerLow,
      borderRadius: AppRadius.card,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.card,
        child: Padding(
          padding: AppSpacing.allMd,
          child: Row(
            children: [
              Image.asset(
                BrandAssets.wordmark,
                height: _logoHeight,
                semanticLabel: AppLocalizations.of(context).pfAbout,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
              const Spacer(),
              if (version.isNotEmpty)
                Text('v${version.split('+').first}', style: context.caption.copyWith(color: context.colors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}
