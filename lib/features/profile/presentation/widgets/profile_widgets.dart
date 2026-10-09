import 'package:flutter/material.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/profile.dart';

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

String formatDate(DateTime? d) => d == null ? '—' : '${d.day} ${_months[d.month - 1]} ${d.year}';

/// Localized label for a `UserInterestType`.
String interestLabel(AppLocalizations l10n, UserInterest i) {
  switch (i) {
    case UserInterest.templeVisits:
      return l10n.pfInterestTempleVisits;
    case UserInterest.routeCompletion:
      return l10n.pfInterestRoutes;
    case UserInterest.pujaPandit:
      return l10n.pfInterestPuja;
    case UserInterest.collectCards:
      return l10n.pfInterestCards;
    case UserInterest.achievements:
      return l10n.pfInterestAchievements;
    case UserInterest.eventsFestivals:
      return l10n.pfInterestFestivals;
    case UserInterest.nearbyTemples:
      return l10n.pfInterestNearby;
    case UserInterest.others:
      return l10n.pfInterestOthers;
  }
}

IconData interestIcon(UserInterest i) {
  switch (i) {
    case UserInterest.templeVisits:
      return AppIcons.temple;
    case UserInterest.routeCompletion:
      return AppIcons.route;
    case UserInterest.pujaPandit:
      return AppIcons.pandit;
    case UserInterest.collectCards:
      return AppIcons.card;
    case UserInterest.achievements:
      return AppIcons.achievement;
    case UserInterest.eventsFestivals:
      return AppIcons.aarti;
    case UserInterest.nearbyTemples:
      return AppIcons.nearby;
    case UserInterest.others:
      return AppIcons.star;
  }
}

String genderLabel(AppLocalizations l10n, ProfileGender g) {
  switch (g) {
    case ProfileGender.male:
      return l10n.pfGenderMale;
    case ProfileGender.female:
      return l10n.pfGenderFemale;
    case ProfileGender.other:
      return l10n.pfGenderOther;
    case ProfileGender.preferNotToSay:
      return l10n.pfGenderPreferNot;
  }
}

/// A small labelled read-only field row used across profile screens.
class ProfileInfoRow extends StatelessWidget {
  const ProfileInfoRow({required this.icon, required this.label, required this.value, this.trailing, super.key});
  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 20, color: context.colors.textSecondary),
          const Gap(AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: context.overline.copyWith(color: context.colors.textSecondary)),
                Text(value, style: context.textTheme.bodyMedium?.semiBold, maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// A compact stat tile (illustrated icon + value + label) for the profile
/// dashboard's 4-up grid.
class ProfileStatTile extends StatelessWidget {
  const ProfileStatTile({required this.icon, required this.value, required this.label, this.color, super.key});
  final IconData icon;
  final String value;
  final String label;
  final Color? color;

  /// Grid cell width : height that fits icon, value and label.
  static const double aspect = 0.78;

  @override
  Widget build(BuildContext context) {
    final c = color ?? context.scheme.primary;
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.sm),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IllustratedIcon(fallbackIcon: icon, color: c, size: 36),
          const Gap(AppSpacing.xs),
          // Narrow 4-up tiles: shrink a long value/label ("Achievements") to
          // fit rather than ellipsizing it.
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value, style: context.textTheme.titleMedium?.bold.withColor(context.scheme.secondary), maxLines: 1),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(label, style: context.caption.copyWith(color: context.colors.textSecondary), maxLines: 1),
          ),
        ],
      ),
    );
  }
}
