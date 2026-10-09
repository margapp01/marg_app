// The devotee's spiritual preferences, shared by onboarding (step 4) and
// Profile → Spiritual Preferences. Each [wire] mirrors a backend enum in
// `prisma/schema.prisma` exactly — never change these values on their own.

import '../../app/localization/app_localizations.dart';

/// A deity the devotee feels drawn to. [wire] mirrors backend `DeityType`
/// (`OTHER` is not offered).
enum DeityChoice {
  shiva('SHIVA'),
  devi('DEVI'),
  vishnu('VISHNU'),
  ganesha('GANESHA'),
  hanuman('HANUMAN'),
  surya('SURYA');

  const DeityChoice(this.wire);

  /// Backend `DeityType` value.
  final String wire;

  static DeityChoice? fromWire(String wire) => _byWire(values, wire, (d) => d.wire);
}

/// How often the devotee visits temples. [wire] mirrors backend
/// `VisitFrequency`.
enum VisitFrequency {
  veryOften('VERY_OFTEN'),
  sometimes('SOMETIMES'),
  rarely('RARELY');

  const VisitFrequency(this.wire);

  /// Backend `VisitFrequency` value.
  final String wire;

  static VisitFrequency? fromWire(String? wire) => wire == null ? null : _byWire(values, wire, (f) => f.wire);
}

/// A yatra type the devotee is drawn to. [wire] mirrors backend `RouteType`
/// (`CUSTOM` is not offered).
enum YatraType {
  jyotirlinga('JYOTIRLINGA'),
  shaktiPeeth('SHAKTI_PEETH'),
  charDham('CHAR_DHAM');

  const YatraType(this.wire);

  /// Backend `RouteType` value.
  final String wire;

  static YatraType? fromWire(String wire) => _byWire(values, wire, (r) => r.wire);
}

T? _byWire<T>(List<T> values, String wire, String Function(T) wireOf) {
  for (final v in values) {
    if (wireOf(v) == wire) return v;
  }
  return null;
}

extension DeityChoiceL10n on DeityChoice {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
        DeityChoice.shiva => l10n.suDeityShiva,
        DeityChoice.devi => l10n.suDeityDevi,
        DeityChoice.vishnu => l10n.suDeityVishnu,
        DeityChoice.ganesha => l10n.suDeityGanesha,
        DeityChoice.hanuman => l10n.suDeityHanuman,
        DeityChoice.surya => l10n.suDeitySurya,
      };
}

extension VisitFrequencyL10n on VisitFrequency {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
        VisitFrequency.veryOften => l10n.suFreqVeryOften,
        VisitFrequency.sometimes => l10n.suFreqSometimes,
        VisitFrequency.rarely => l10n.suFreqRarely,
      };

  String localizedSubtitle(AppLocalizations l10n) => switch (this) {
        VisitFrequency.veryOften => l10n.suFreqVeryOftenSub,
        VisitFrequency.sometimes => l10n.suFreqSometimesSub,
        VisitFrequency.rarely => l10n.suFreqRarelySub,
      };
}

extension YatraTypeL10n on YatraType {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
        YatraType.jyotirlinga => l10n.suRouteJyotirlinga,
        YatraType.shaktiPeeth => l10n.suRouteShaktiPeeth,
        YatraType.charDham => l10n.suRouteCharDham,
      };
}
