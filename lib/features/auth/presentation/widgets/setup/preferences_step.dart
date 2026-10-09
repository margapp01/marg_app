import 'package:flutter/material.dart';

import '../../../../../app/localization/app_localizations.dart';
import '../../../../../core/models/spiritual_choices.dart';
import '../../../../../shared/design_system.dart';
import 'setup_common.dart';
import 'setup_models.dart';

/// Step 4 — "Your Spiritual Preferences": favourite deities, how often the
/// devotee visits temples, the yatras they're drawn to, and the app language.
class SpiritualStep extends StatelessWidget {
  const SpiritualStep({
    required this.deities,
    required this.onToggleDeity,
    required this.frequency,
    required this.onFrequency,
    required this.routeTypes,
    required this.onToggleRouteType,
    required this.onClearRouteTypes,
    required this.language,
    required this.onLanguage,
    super.key,
  });

  final Set<DeityChoice> deities;
  final ValueChanged<DeityChoice> onToggleDeity;
  final VisitFrequency? frequency;
  final ValueChanged<VisitFrequency> onFrequency;

  /// Empty means "Not sure yet".
  final Set<YatraType> routeTypes;
  final ValueChanged<YatraType> onToggleRouteType;
  final VoidCallback onClearRouteTypes;
  final SetupLanguage language;
  final ValueChanged<SetupLanguage> onLanguage;

  static const int _deitiesPerRow = 4;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: AppSpacing.screenAll,
      children: [
        SetupHeader(title: l10n.suSpiritualTitle, subtitle: l10n.suSpiritualSubtitle),
        const Gap(AppSpacing.xl),
        LabeledField(
          label: l10n.suPreferredDeities,
          hint: l10n.suSelectAny,
          child: LayoutBuilder(
            builder: (context, constraints) {
              const gap = AppSpacing.sm;
              final width = (constraints.maxWidth - gap * (_deitiesPerRow - 1)) / _deitiesPerRow;
              return Wrap(
                alignment: WrapAlignment.center,
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final d in DeityChoice.values)
                    SizedBox(
                      width: width,
                      child: ChoiceTile(
                        icon: d == DeityChoice.surya ? AppIcons.sun : AppIcons.temple,
                        asset: deityAsset(d.wire),
                        accent: deityColor(context, d.wire),
                        label: d.localizedLabel(l10n),
                        selected: deities.contains(d),
                        onTap: () => onToggleDeity(d),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        const Gap(AppSpacing.xl),
        LabeledField(
          label: l10n.suVisitFrequency,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final f in VisitFrequency.values) ...[
                Expanded(
                  child: ChoiceTile(
                    label: f.localizedLabel(l10n),
                    subtitle: f.localizedSubtitle(l10n),
                    selected: frequency == f,
                    onTap: () => onFrequency(f),
                  ),
                ),
                if (f != VisitFrequency.values.last) const Gap.h(AppSpacing.sm),
              ],
            ],
          ),
        ),
        const Gap(AppSpacing.xl),
        LabeledField(
          label: l10n.suInterestedIn,
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final r in YatraType.values)
                AppFilterChip(
                  label: r.localizedLabel(l10n),
                  icon: AppIcons.route,
                  selected: routeTypes.contains(r),
                  onSelected: (_) => onToggleRouteType(r),
                ),
              AppFilterChip(
                label: l10n.suRouteNotSure,
                icon: AppIcons.help,
                selected: routeTypes.isEmpty,
                onSelected: (_) => onClearRouteTypes(),
              ),
            ],
          ),
        ),
        const Gap(AppSpacing.xl),
        LabeledField(
          label: l10n.suLanguage,
          child: Row(
            children: [
              for (final lang in SetupLanguage.values) ...[
                Expanded(
                  child: ChoiceTile(
                    label: lang.localizedLabel(l10n),
                    selected: language == lang,
                    onTap: () => onLanguage(lang),
                  ),
                ),
                if (lang != SetupLanguage.values.last) const Gap.h(AppSpacing.sm),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
