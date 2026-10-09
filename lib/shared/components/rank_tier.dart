import '../../app/localization/app_localizations.dart';

/// Friendly label for a backend `RankTier` (the passport level) — shared by
/// Passport, Profile and Leaderboards.
String tierLabel(AppLocalizations l10n, String tier) {
  switch (tier.toUpperCase()) {
    case 'MAHAYOGI':
      return l10n.ppTierMahayogi;
    case 'SAINT':
      return l10n.ppTierSaint;
    case 'SAGE':
      return l10n.ppTierSage;
    case 'DEVOTEE':
      return l10n.ppTierDevotee;
    case 'PILGRIM':
      return l10n.ppTierPilgrim;
    case 'EXPLORER':
      return l10n.ppTierExplorer;
    default:
      return l10n.ppTierSeeker;
  }
}
