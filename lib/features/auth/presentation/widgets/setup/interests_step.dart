import 'package:flutter/material.dart';

import '../../../../../app/localization/app_localizations.dart';
import '../../../../../shared/design_system.dart';
import 'setup_common.dart';
import 'setup_models.dart';

/// Step 3 — "What Brings You Here?": the areas of interest that personalise
/// Home and suggestions.
class InterestsStep extends StatelessWidget {
  const InterestsStep({required this.selected, required this.onToggle, super.key});

  final Set<SetupInterest> selected;
  final ValueChanged<SetupInterest> onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: AppSpacing.screenAll,
      children: [
        SetupHeader(title: l10n.suBringsTitle, subtitle: l10n.suBringsSubtitle),
        const Gap(AppSpacing.xl),
        for (final interest in SetupInterest.selectable) ...[
          OptionCard(
            icon: interest.icon,
            title: interest.localizedLabel(l10n),
            subtitle: interest.localizedSubtitle(l10n),
            accent: _accent(context, interest),
            selected: selected.contains(interest),
            onTap: () => onToggle(interest),
          ),
          const Gap(AppSpacing.sm),
        ],
      ],
    );
  }

  Color _accent(BuildContext context, SetupInterest interest) {
    final p = context.palette;
    return switch (interest) {
      SetupInterest.templeVisits => p.accentSaffron,
      SetupInterest.routeCompletion => p.accentBlue,
      SetupInterest.pujaPandit => p.accentGreen,
      SetupInterest.collectCards => p.accentRose,
      SetupInterest.achievements => p.accentAmber,
      SetupInterest.eventsFestivals => p.accentViolet,
      SetupInterest.nearbyTemples => p.accentTeal,
      SetupInterest.others => p.accentGreen,
    };
  }
}
