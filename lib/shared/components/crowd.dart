import 'package:flutter/widgets.dart';

import '../../app/localization/app_localizations.dart';
import '../../core/extensions/context_extensions.dart';

/// Localized label + accent colour for a backend `CrowdLevel`
/// (LOW / MODERATE / HIGH / VERY_HIGH / FULL) — one mapping for temple detail,
/// Home's Temple Intelligence and anywhere crowd is shown.
({String label, Color color}) crowdMeta(BuildContext context, AppLocalizations l10n, String level) {
  final palette = context.palette;
  switch (level.toUpperCase()) {
    case 'MODERATE':
      return (label: l10n.tdCrowdModerate, color: palette.crowdModerate);
    case 'HIGH':
      return (label: l10n.tdCrowdHigh, color: palette.crowdHigh);
    case 'VERY_HIGH':
    case 'FULL':
      return (label: l10n.tdCrowdVeryHigh, color: palette.crowdVeryHigh);
    default:
      return (label: l10n.tdCrowdLow, color: palette.crowdLow);
  }
}
