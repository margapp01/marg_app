import 'package:flutter/widgets.dart';

import '../../app/theme/app_icons.dart';
import 'empty_view.dart';
import 'state_art.dart';

/// Ready-made empty states for the app's list screens. Each wraps [EmptyView]
/// with the right MARG terminology and icon; pass an [action] to offer a next
/// step (e.g. "Explore temples").

class SearchEmpty extends StatelessWidget {
  const SearchEmpty({this.query, super.key});
  final String? query;

  @override
  Widget build(BuildContext context) => EmptyView(
        art: StateArt.noResults,
        icon: AppIcons.search,
        title: 'No results',
        message: query == null
            ? 'Try a different search.'
            : 'Nothing matched “$query”. Try a different search.',
      );
}

class NotificationsEmpty extends StatelessWidget {
  const NotificationsEmpty({super.key});

  @override
  Widget build(BuildContext context) => const EmptyView(
        art: StateArt.notifications,
        icon: AppIcons.notifications,
        title: 'You’re all caught up',
        message: 'Notifications about your journey will appear here.',
      );
}

class PassportEmpty extends StatelessWidget {
  const PassportEmpty({this.action, super.key});
  final Widget? action;

  @override
  Widget build(BuildContext context) => EmptyView(
        art: StateArt.noVisits,
        icon: AppIcons.passport,
        title: 'Your passport awaits',
        message: 'Visit a temple to add your first verified stamp.',
        action: action,
      );
}

class VisitsEmpty extends StatelessWidget {
  const VisitsEmpty({this.action, super.key});
  final Widget? action;

  @override
  Widget build(BuildContext context) => EmptyView(
        art: StateArt.noVisits,
        icon: AppIcons.visit,
        title: 'No visits yet',
        message: 'Check in at a nearby temple to record your first visit.',
        action: action,
      );
}

class RoutesEmpty extends StatelessWidget {
  const RoutesEmpty({this.action, super.key});
  final Widget? action;

  @override
  Widget build(BuildContext context) => EmptyView(
        art: StateArt.journey,
        icon: AppIcons.route,
        title: 'No routes yet',
        message: 'Pilgrimage routes you start will show up here.',
        action: action,
      );
}

class CardsEmpty extends StatelessWidget {
  const CardsEmpty({super.key});

  @override
  Widget build(BuildContext context) => const EmptyView(
        art: StateArt.collection,
        icon: AppIcons.card,
        title: 'No cards collected',
        message: 'Complete visits and achievements to unlock cards.',
      );
}

class LeaderboardEmpty extends StatelessWidget {
  const LeaderboardEmpty({super.key});

  @override
  Widget build(BuildContext context) => const EmptyView(
        art: StateArt.leaderboard,
        icon: AppIcons.leaderboard,
        title: 'No rankings yet',
        message: 'Rankings appear once devotees start earning points.',
      );
}

class ReferralsEmpty extends StatelessWidget {
  const ReferralsEmpty({this.action, super.key});
  final Widget? action;

  @override
  Widget build(BuildContext context) => EmptyView(
        art: StateArt.referrals,
        icon: AppIcons.referral,
        title: 'No referrals yet',
        message: 'Invite friends and your referrals will appear here.',
        action: action,
      );
}
