import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The user's explicit locale override.
///
/// `null` (the default) means "follow the device locale"; Flutter then
/// resolves against [AppLocalizations.supportedLocales] with English as the
/// template fallback. Settings will assign [locale] in a later phase.
class LocaleController extends Notifier<Locale?> {
  @override
  Locale? build() => null;

  set locale(Locale? value) => state = value;
}

final localeControllerProvider =
    NotifierProvider<LocaleController, Locale?>(LocaleController.new);
