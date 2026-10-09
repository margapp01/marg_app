/// Single import point for localization. Features import this file, never
/// the generated `gen/` output directly, so the codegen layout can change
/// without touching feature code.
///
/// Strings live in `arb/app_en.arb` (template) and `arb/app_hi.arb`;
/// `flutter gen-l10n` regenerates `gen/` from them.
library;

export 'gen/app_localizations_gen.dart';
