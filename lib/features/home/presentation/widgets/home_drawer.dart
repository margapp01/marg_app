import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/router/route_names.dart';
import '../../../../shared/design_system.dart';
import '../controllers/home_controller.dart';

/// The app menu (Home ☰). Groups every destination that isn't a bottom tab,
/// so nothing in the app is more than two taps away.
class HomeDrawer extends ConsumerWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final profile = ref.watch(homeControllerProvider.select((s) => s.valueOrNull?.profile));

    // Close the drawer first, then navigate (push keeps the tab underneath).
    void open(String name, {bool tab = false}) {
      Navigator.of(context).pop();
      tab ? context.goNamed(name) : context.pushNamed(name);
    }

    return Drawer(
      backgroundColor: context.scheme.surface,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          children: [
            _DrawerHeader(
              name: profile?.name,
              photo: profile?.profilePhoto,
              city: profile?.city,
              onTap: () => open(RouteNames.profile, tab: true),
            ),
            _Group(l10n.drawerJourney),
            _Item(AppIcons.passport, l10n.titlePassport, () => open(RouteNames.passport, tab: true)),
            _Item(AppIcons.route, l10n.homeActionMyRoutes, () => open(RouteNames.routes, tab: true)),
            _Item(AppIcons.card, l10n.homeSectionCards, () => open(RouteNames.cards)),
            _Item(AppIcons.achievement, l10n.titleAchievements, () => open(RouteNames.achievements)),
            _Item(AppIcons.leaderboard, l10n.titleLeaderboards, () => open(RouteNames.leaderboards)),
            _Item(AppIcons.favorite, l10n.homeActionSaved, () => open(RouteNames.exploreSaved)),
            _Group(l10n.drawerDiscover),
            _Item(AppIcons.blog, l10n.kbKnowledgeHub, () => open(RouteNames.knowledge)),
            _Item(AppIcons.festival, l10n.kbFestivals, () => open(RouteNames.knowledgeFestivals)),
            _Item(AppIcons.quote, l10n.kbDailyQuotes, () => open(RouteNames.knowledgeQuotes)),
            _Item(AppIcons.notifications, l10n.titleNotifications, () => open(RouteNames.notifications)),
            _Group(l10n.drawerAccount),
            _Item(AppIcons.referral, l10n.homeReferralTitle, () => open(RouteNames.referrals)),
            _Item(AppIcons.settings, l10n.pfAppPreferences, () => open(RouteNames.profileAppPreferences)),
            _Item(AppIcons.support, l10n.pfHelpSupport, () => open(RouteNames.profileHelp)),
            _Item(AppIcons.info, l10n.pfAbout, () => open(RouteNames.knowledgeAbout)),
          ],
        ),
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({required this.name, required this.photo, required this.city, required this.onTap});

  final String? name;
  final String? photo;
  final String? city;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.md),
      child: AppCard(
        gradient: AppGradients.peach,
        variant: AppCardVariant.filled,
        onTap: onTap,
        child: Row(
          children: [
            AppAvatar(imageUrl: photo, name: name, radius: 26),
            const Gap.h(AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name ?? AppLocalizations.of(context).homeDevotee,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.displayText.titleLarge,
                  ),
                  if (city != null)
                    Text(city!, style: context.caption.copyWith(color: context.colors.textSecondary)),
                ],
              ),
            ),
            Icon(AppIcons.chevronRight, color: context.colors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.xs),
      child: Text(label.toUpperCase(), style: context.overline.copyWith(color: context.colors.textSecondary)),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item(this.icon, this.label, this.onTap);

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      leading: Icon(icon, color: context.scheme.primary),
      title: Text(label, style: context.textTheme.bodyLarge?.medium),
      onTap: onTap,
    );
  }
}
