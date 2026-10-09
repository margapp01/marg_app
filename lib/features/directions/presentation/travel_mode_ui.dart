import 'dart:math' as math;

import '../../../app/localization/app_localizations.dart';
import '../domain/route_plan.dart';

/// Localized name of a [TravelMode] ("Drive", "Bike", "Walk").
String travelModeLabel(AppLocalizations l10n, TravelMode mode) => switch (mode) {
      TravelMode.drive => l10n.dirDrive,
      TravelMode.bike => l10n.dirBike,
      TravelMode.walk => l10n.dirWalk,
    };

/// A trip duration: "25 min", "22 h 28 min", or past a day "15 d 9 h".
String formatTravelTime(AppLocalizations l10n, double seconds) {
  final minutes = math.max(1, (seconds / 60).round());
  if (minutes < 60) return l10n.dirMinutes(minutes);
  // Past a day (a long ride), minutes are noise — "15 d 9 h", not "369 h 12 min".
  if (minutes < Duration.minutesPerDay) return l10n.dirHoursMinutes(minutes ~/ 60, minutes % 60);
  final hours = (minutes / 60).round();
  return l10n.dirDaysHours(hours ~/ Duration.hoursPerDay, hours % Duration.hoursPerDay);
}
