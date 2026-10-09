import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/localization/locale_provider.dart';
import '../../../../core/models/spiritual_choices.dart';
import '../../../../shared/design_system.dart';
import '../../../notifications/presentation/controllers/notification_controllers.dart' show upcomingFestivalsProvider;
import '../../data/repository/profile_repository.dart';
import '../../domain/entities/profile.dart';
import '../controllers/profile_controllers.dart';
import '../widgets/profile_widgets.dart';

/// Screen 3 — Spiritual Preferences. Edits every spiritual field the backend
/// models on `PATCH /my/profile`: favourite deities, visit frequency, preferred
/// yatras, nearby radius, festival interests, interests and language — the
/// same choices as onboarding step 4, drawn with the same tiles.
class SpiritualPreferencesPage extends ConsumerWidget {
  const SpiritualPreferencesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(profileProvider);
    return async.when(
      loading: () => Scaffold(appBar: AppBar(title: Text(l10n.pfSpiritualPreferences)), body: const LoadingView()),
      error: (_, _) => Scaffold(
        appBar: AppBar(title: Text(l10n.pfSpiritualPreferences)),
        body: ErrorView(title: l10n.pfErrorTitle, message: l10n.pfErrorBody, onRetry: () => ref.invalidate(profileProvider)),
      ),
      data: (profile) => _Form(profile: profile),
    );
  }
}

class _Form extends ConsumerStatefulWidget {
  const _Form({required this.profile});
  final Profile profile;
  @override
  ConsumerState<_Form> createState() => _FormState();
}

class _FormState extends ConsumerState<_Form> {
  static const int _minRadius = 5;
  static const int _maxRadius = 100;
  static const int _radiusStep = 5;
  static const int _deitiesPerRow = 3;

  late final Set<DeityChoice> _deities = {
    for (final w in widget.profile.favoriteDeities) ?DeityChoice.fromWire(w),
  };
  late VisitFrequency? _frequency = VisitFrequency.fromWire(widget.profile.visitFrequency);
  late final Set<YatraType> _yatras = {
    for (final w in widget.profile.preferredRouteTypes) ?YatraType.fromWire(w),
  };
  late final Set<String> _festivals = {...widget.profile.festivalInterests};
  late final Set<UserInterest> _interests = {
    for (final w in widget.profile.interests) ?UserInterest.fromWire(w),
  };
  late final int _initialRadius = widget.profile.nearbyRadiusKm.clamp(_minRadius, _maxRadius);
  late int _radius = _initialRadius;
  late String _language = widget.profile.preferredLanguage;
  bool _saving = false;

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _saving = true);
    try {
      await ref.read(profileRepositoryProvider).updateProfile(
            favoriteDeities: [for (final d in _deities) d.wire],
            visitFrequency: _frequency?.wire,
            preferredRouteTypes: [for (final y in _yatras) y.wire],
            festivalInterests: _festivals.toList(),
            // Only send the radius when touched, so an out-of-slider value
            // saved elsewhere is never silently clamped.
            nearbyRadiusKm: _radius == _initialRadius ? null : _radius,
            interests: [for (final i in _interests) i.wire],
            preferredLanguage: _language,
          );
      ref.invalidate(profileProvider);
      if (_language != widget.profile.preferredLanguage) {
        ref.read(localeControllerProvider.notifier).locale = Locale(_language.toLowerCase());
      }
      if (mounted) {
        AppSnackbar.success(context, l10n.pfSaved);
        context.pop();
      }
    } catch (_) {
      if (mounted) AppSnackbar.error(context, l10n.pfSaveFailed);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _toggle<T>(Set<T> set, T value) => setState(() => set.contains(value) ? set.remove(value) : set.add(value));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const section = AppSpacing.allMd;
    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(title: Text(l10n.pfSpiritualPreferences)),
      bottomNavigationBar: BottomActionBar(
        child: AppButton.primary(label: l10n.pfSavePreferences, busy: _saving, onPressed: _saving ? null : _save),
      ),
      body: ListView(
        padding: AppSpacing.screenAll,
        children: [
          IntroBanner(icon: AppIcons.lotus, title: l10n.pfSpiritualHeroTitle, message: l10n.pfSpiritualHeroBody).fadeIn(),
          const Gap(AppSpacing.xl),
          SettingsGroup(title: l10n.suPreferredDeities, padding: section, children: [_deityGrid(l10n)]),
          const Gap(AppSpacing.xl),
          SettingsGroup(
            title: l10n.suVisitFrequency,
            padding: section,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final f in VisitFrequency.values) ...[
                    Expanded(
                      child: ChoiceTile(
                        label: f.localizedLabel(l10n),
                        subtitle: f.localizedSubtitle(l10n),
                        selected: _frequency == f,
                        onTap: () => setState(() => _frequency = f),
                      ),
                    ),
                    if (f != VisitFrequency.values.last) const Gap.h(AppSpacing.sm),
                  ],
                ],
              ),
            ],
          ),
          const Gap(AppSpacing.xl),
          SettingsGroup(
            title: l10n.pfYatraTypes,
            padding: section,
            children: [
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final y in YatraType.values)
                    AppFilterChip(
                      label: y.localizedLabel(l10n),
                      icon: AppIcons.route,
                      selected: _yatras.contains(y),
                      onSelected: (_) => _toggle(_yatras, y),
                    ),
                  AppFilterChip(
                    label: l10n.suRouteNotSure,
                    icon: AppIcons.help,
                    selected: _yatras.isEmpty,
                    onSelected: (_) => setState(_yatras.clear),
                  ),
                ],
              ),
            ],
          ),
          const Gap(AppSpacing.xl),
          SettingsGroup(title: l10n.pfNearbyRadius, padding: section, children: [_radiusPicker(l10n)]),
          _festivalSection(l10n),
          const Gap(AppSpacing.xl),
          SettingsGroup(
            title: l10n.pfInterests,
            padding: section,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Hint(l10n.pfInterestsHint),
                  const Gap(AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (final i in UserInterest.selectable)
                        AppFilterChip(
                          label: interestLabel(l10n, i),
                          icon: interestIcon(i),
                          selected: _interests.contains(i),
                          onSelected: (_) => _toggle(_interests, i),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const Gap(AppSpacing.xl),
          SettingsGroup(
            title: l10n.pfLanguage,
            padding: section,
            children: [
              Row(
                children: [
                  Expanded(child: _languageTile('EN', l10n.pfLanguageEnglish)),
                  const Gap.h(AppSpacing.sm),
                  Expanded(child: _languageTile('HI', l10n.pfLanguageHindi)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _deityGrid(AppLocalizations l10n) => ChoiceGrid(
        columns: _deitiesPerRow,
        children: [
          for (final d in DeityChoice.values)
            ChoiceTile(
              icon: d == DeityChoice.surya ? AppIcons.sun : AppIcons.temple,
              asset: deityAsset(d.wire),
              accent: deityColor(context, d.wire),
              label: d.localizedLabel(l10n),
              selected: _deities.contains(d),
              onTap: () => _toggle(_deities, d),
            ),
        ],
      );

  Widget _radiusPicker(AppLocalizations l10n) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _Hint(l10n.pfNearbyRadiusHint)),
              const Gap.h(AppSpacing.sm),
              AppBadge(label: l10n.pfRadiusKm(_radius), tone: AppBadgeTone.primary),
            ],
          ),
          Slider(
            value: _radius.toDouble(),
            min: _minRadius.toDouble(),
            max: _maxRadius.toDouble(),
            divisions: (_maxRadius - _minRadius) ~/ _radiusStep,
            label: l10n.pfRadiusKm(_radius),
            onChanged: (v) => setState(() => _radius = v.round()),
          ),
        ],
      );

  /// Festival chips from the upcoming-festivals feed; hidden when there are
  /// none (saved slugs outside the feed are kept as-is).
  Widget _festivalSection(AppLocalizations l10n) {
    final festivals = ref.watch(upcomingFestivalsProvider).valueOrNull ?? const [];
    if (festivals.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xl),
      child: SettingsGroup(
        title: l10n.pfFestivalInterests,
        padding: AppSpacing.allMd,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Hint(l10n.pfFestivalInterestsHint),
              const Gap(AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final f in festivals)
                    if (f.slug.isNotEmpty)
                      AppFilterChip(
                        label: f.name,
                        icon: AppIcons.festival,
                        selected: _festivals.contains(f.slug),
                        onSelected: (_) => _toggle(_festivals, f.slug),
                      ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _languageTile(String code, String label) => ChoiceTile(
        icon: AppIcons.language,
        label: label,
        selected: _language == code,
        onTap: () => setState(() => _language = code),
      );
}

class _Hint extends StatelessWidget {
  const _Hint(this.text);
  final String text;
  @override
  Widget build(BuildContext context) =>
      Text(text, style: context.textTheme.bodySmall?.copyWith(color: context.colors.textSecondary));
}
