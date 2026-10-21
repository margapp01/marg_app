import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/localization/app_localizations.dart';
import '../../app/theme/app_icons.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/location/captured_location.dart';
import '../../core/location/chosen_city.dart';
import '../../core/location/location_access.dart';
import '../../core/location/location_service.dart';
import '../../core/location/place_lookup.dart';
import '../components/app_text_field.dart';
import '../sheets/app_sheets.dart';
import '../sheets/location_permission_sheet.dart';
import '../tiles/app_list_tile.dart';

/// The devotee's city, set by device location or by searching a city name.
///
/// With [gpsFirst] (onboarding) a tap asks for location the way Home does —
/// the system dialog, then the "Enable location" sheet — and if location is
/// still declined, opens the city search instead. Otherwise a tap opens the
/// city search, whose first row is "Use my current location".
///
/// A searched city is remembered on the device ([ChosenCityStore]) so Home and
/// Nearby can show the temples around it; [onPicked] receives either kind as a
/// [CapturedLocation] for `PUT /my/location`.
class CityField extends ConsumerStatefulWidget {
  const CityField({required this.onPicked, this.value, this.gpsFirst = false, super.key});

  /// The current city label ("Pune, Maharashtra"); null shows the prompt.
  final String? value;
  final bool gpsFirst;
  final ValueChanged<CapturedLocation> onPicked;

  @override
  ConsumerState<CityField> createState() => _CityFieldState();
}

class _CityFieldState extends ConsumerState<CityField> {
  bool _busy = false;

  /// Located, but no geocoder could name the place: say "Current location"
  /// rather than showing the empty prompt again.
  bool _unnamed = false;

  Future<void> _detect() async {
    setState(() => _busy = true);
    try {
      var access = await ref.read(locationAccessProvider.notifier).askDirectly();
      if (access != LocationAccess.granted && mounted) {
        final granted = await LocationPermissionSheet.show(context);
        access = granted ? LocationAccess.granted : access;
      }
      if (!mounted) return;
      if (access != LocationAccess.granted) {
        await _search(offerCurrent: false);
        return;
      }
      final res = await ref.read(locationServiceProvider).capture();
      if (!res.isSuccess) {
        if (mounted) await _search(offerCurrent: false);
        return;
      }
      var captured = res.location!;
      final place = await ref.read(placeLookupProvider).reverse(
            latitude: captured.latitude,
            longitude: captured.longitude,
          );
      if (!place.isEmpty) captured = captured.withPlace(place);
      if (mounted) setState(() => _unnamed = place.isEmpty);
      // Real location wins from now on; forget a hand-picked city.
      await ref.read(chosenCityStoreProvider).clear();
      widget.onPicked(captured);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _search({bool offerCurrent = true}) async {
    final choice = await CityPickerSheet.show(context, offerCurrent: offerCurrent);
    if (choice == null || !mounted) return;
    if (choice.useCurrentLocation) {
      await _detect();
      return;
    }
    final city = choice.city!;
    setState(() => _unnamed = false);
    await ref.read(chosenCityStoreProvider).save(city);
    widget.onPicked(city.toCaptured());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final value = widget.value != null && widget.value!.isNotEmpty
        ? widget.value
        : (_unnamed ? l10n.cityCurrentLocation : null);
    final hasValue = value != null && value.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          button: true,
          label: hasValue ? value : l10n.cityTapToChoose,
          excludeSemantics: true,
          child: Material(
            color: context.colors.card,
            borderRadius: AppRadius.input,
            child: InkWell(
              onTap: _busy ? null : (widget.gpsFirst ? _detect : _search),
              borderRadius: AppRadius.input,
              child: Container(
                constraints: const BoxConstraints(minHeight: 56),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                decoration: BoxDecoration(
                  borderRadius: AppRadius.input,
                  border: Border.all(color: hasValue ? context.scheme.primary.withValues(alpha: 0.5) : context.colors.border),
                ),
                child: Row(
                  children: [
                    Icon(AppIcons.location, size: 20, color: hasValue ? context.scheme.primary : context.colors.textSecondary),
                    const Gap.h(AppSpacing.sm),
                    Expanded(
                      child: Text(
                        _busy ? l10n.cityDetecting : (hasValue ? value : l10n.cityTapToChoose),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: hasValue && !_busy ? context.scheme.onSurface : context.colors.textSecondary,
                        ),
                      ),
                    ),
                    if (_busy)
                      const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    else
                      Icon(
                        widget.gpsFirst ? AppIcons.myLocation : AppIcons.search,
                        size: 20,
                        color: context.scheme.primary,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (widget.gpsFirst)
          TextButton.icon(
            onPressed: _busy ? null : () => _search(offerCurrent: false),
            icon: const Icon(AppIcons.search, size: 18),
            label: Text(l10n.citySearchInstead),
          ),
      ],
    );
  }
}

/// What the devotee chose in [CityPickerSheet].
class CityChoice {
  const CityChoice.current()
      : useCurrentLocation = true,
        city = null;
  const CityChoice.city(ChosenCity this.city) : useCurrentLocation = false;

  final bool useCurrentLocation;
  final ChosenCity? city;
}

/// "Choose your city": search any city by name (with [offerCurrent], "Use my
/// current location" on top). Resolves to the choice, or null if dismissed.
class CityPickerSheet extends ConsumerStatefulWidget {
  const CityPickerSheet({this.offerCurrent = true, super.key});

  final bool offerCurrent;

  static Future<CityChoice?> show(BuildContext context, {bool offerCurrent = true}) {
    return AppSheets.show<CityChoice>(
      context,
      padded: false,
      builder: (_) => CityPickerSheet(offerCurrent: offerCurrent),
    );
  }

  @override
  ConsumerState<CityPickerSheet> createState() => _CityPickerSheetState();
}

class _CityPickerSheetState extends ConsumerState<CityPickerSheet> {
  static const Duration _debounce = Duration(milliseconds: 350);

  Timer? _timer;
  String _query = '';
  bool _loading = false;
  bool _failed = false;
  List<ChosenCity> _results = const [];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onChanged(String value) {
    _query = value.trim();
    _timer?.cancel();
    if (_query.length < 2) {
      setState(() {
        _results = const [];
        _loading = false;
        _failed = false;
      });
      return;
    }
    setState(() => _loading = true);
    _timer = Timer(_debounce, () => _run(_query));
  }

  Future<void> _run(String query) async {
    try {
      final results = await ref.read(citySearchProvider).search(query);
      if (!mounted || query != _query) return;
      setState(() {
        _results = results;
        _loading = false;
        _failed = false;
      });
    } catch (_) {
      if (!mounted || query != _query) return;
      setState(() {
        _loading = false;
        _failed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final muted = context.textTheme.bodyMedium?.withColor(context.colors.textSecondary);
    final Widget body;
    if (_loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_failed) {
      body = Center(child: Text(l10n.cityError, style: muted, textAlign: TextAlign.center));
    } else if (_query.length < 2) {
      body = Center(child: Text(l10n.cityTypeMore, style: muted, textAlign: TextAlign.center));
    } else if (_results.isEmpty) {
      body = Center(child: Text(l10n.cityNoResults, style: muted, textAlign: TextAlign.center));
    } else {
      body = ListView.builder(
        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
        itemCount: _results.length,
        itemBuilder: (context, i) {
          final c = _results[i];
          return AppListTile(
            leadingIcon: AppIcons.location,
            iconColor: context.scheme.primary,
            title: c.name,
            subtitle: c.subtitle.isEmpty ? null : c.subtitle,
            onTap: () => Navigator.of(context).pop(CityChoice.city(c)),
          );
        },
      );
    }
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.85,
      child: AppSheetLayout(
        title: l10n.cityChoose,
        icon: AppIcons.location,
        scrollable: false,
        bodyPadding: EdgeInsets.zero,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xs),
              child: AppTextField(
                hint: l10n.citySearchHint,
                prefixIcon: AppIcons.search,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                onChanged: _onChanged,
              ),
            ),
            if (widget.offerCurrent)
              AppListTile(
                leadingIcon: AppIcons.myLocation,
                iconColor: context.scheme.primary,
                title: l10n.cityUseCurrent,
                subtitle: l10n.cityUseCurrentHint,
                onTap: () => Navigator.of(context).pop(const CityChoice.current()),
              ),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}
