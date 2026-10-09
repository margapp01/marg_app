import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/config/app_config.dart';
import '../../../../../app/localization/app_localizations.dart';
import '../../../../../core/location/captured_location.dart';
import '../../../../../core/location/location_service.dart';
import '../../../../../core/location/mapbox_geocoder.dart';
import '../../../../../shared/design_system.dart';

/// The "City / Location" field: on tap, request permission, capture a GPS fix,
/// reverse-geocode it to a city and lift it to the parent. Persistence happens
/// in the final batch submit (there may be no session yet).
class CityLocationField extends ConsumerStatefulWidget {
  const CityLocationField({required this.captured, required this.onCaptured, super.key});

  final CapturedLocation? captured;
  final ValueChanged<CapturedLocation> onCaptured;

  @override
  ConsumerState<CityLocationField> createState() => _CityLocationFieldState();
}

enum _Phase { idle, loading, done, denied, blocked }

class _CityLocationFieldState extends ConsumerState<CityLocationField> {
  late _Phase _phase = widget.captured != null ? _Phase.done : _Phase.idle;

  Future<void> _detect() async {
    setState(() => _phase = _Phase.loading);
    final res = await ref.read(locationServiceProvider).capture();

    if (!res.isSuccess) {
      if (!mounted) return;
      setState(() {
        _phase = res.status == LocationStatus.deniedForever || res.status == LocationStatus.serviceDisabled
            ? _Phase.blocked
            : _Phase.denied;
      });
      return;
    }

    var captured = res.location!;
    // Reverse-geocode to city/state/country (best-effort).
    if (ref.read(appConfigProvider).hasMapbox) {
      try {
        final place = await ref.read(mapboxGeocoderProvider).reverse(
              latitude: captured.latitude,
              longitude: captured.longitude,
            );
        if (!place.isEmpty) captured = captured.withPlace(place);
      } catch (_) {/* keep coordinates without a place */}
    }

    widget.onCaptured(captured);
    if (mounted) setState(() => _phase = _Phase.done);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = widget.captured?.place?.label;
    final loading = _phase == _Phase.loading;
    final text = switch (_phase) {
      _Phase.loading => l10n.suGettingLocation,
      _Phase.done when label != null && label.isNotEmpty => label,
      _Phase.done => l10n.suLocationEnabled,
      _ => l10n.suCityTapToDetect,
    };
    final hasValue = _phase == _Phase.done;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          button: true,
          label: text,
          child: Material(
            color: context.colors.card,
            borderRadius: AppRadius.mdAll,
            child: InkWell(
              onTap: loading ? null : _detect,
              borderRadius: AppRadius.mdAll,
              child: Container(
                constraints: const BoxConstraints(minHeight: 52),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                decoration: BoxDecoration(
                  borderRadius: AppRadius.mdAll,
                  border: Border.all(color: context.colors.border),
                ),
                child: Row(
                  children: [
                    Icon(AppIcons.location, size: 20, color: context.colors.textSecondary),
                    const Gap.h(AppSpacing.sm),
                    Expanded(
                      child: Text(
                        text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: hasValue ? context.scheme.onSurface : context.colors.textSecondary,
                        ),
                      ),
                    ),
                    if (loading)
                      const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    else
                      Icon(
                        hasValue ? AppIcons.success : AppIcons.myLocation,
                        size: 20,
                        color: hasValue ? context.colors.success : context.scheme.primary,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_phase == _Phase.denied || _phase == _Phase.blocked) ...[
          const Gap(AppSpacing.xs),
          Text(
            _phase == _Phase.blocked ? l10n.suLocationBlocked : l10n.suLocationDenied,
            style: context.textTheme.bodySmall?.copyWith(color: context.colors.textSecondary),
          ),
          if (_phase == _Phase.blocked)
            TextButton.icon(
              onPressed: () => ref.read(locationServiceProvider).openSettings(),
              icon: const Icon(AppIcons.settings, size: 18),
              label: Text(l10n.suOpenSettings),
            ),
        ],
      ],
    );
  }
}
