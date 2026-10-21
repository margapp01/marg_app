import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/localization/app_localizations.dart';
import '../../app/theme/app_icons.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/models/country_dial_code.dart';
import '../components/app_text_field.dart';
import '../sheets/app_sheets.dart';
import '../tiles/app_list_tile.dart';

/// Phone number input with a country calling-code prefix and digits-only
/// entry. With [onCountryChanged] the prefix is a picker (flag + code ▾) that
/// opens a searchable list of every country; without it the code is fixed.
/// The digit limit follows the chosen [country].
class PhoneField extends StatelessWidget {
  const PhoneField({
    this.controller,
    this.country = CountryDialCode.india,
    this.onCountryChanged,
    this.label,
    this.floatingLabel = true,
    this.hint,
    this.errorText,
    this.enabled = true,
    this.validator,
    this.onChanged,
    super.key,
  });

  final TextEditingController? controller;
  final CountryDialCode country;
  final ValueChanged<CountryDialCode>? onCountryChanged;
  final String? label;

  /// False when an external label sits above the field (forms with
  /// `LabeledField`), so the input shows only its hint.
  final bool floatingLabel;
  final String? hint;
  final String? errorText;
  final bool enabled;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  Future<void> _pick(BuildContext context) async {
    final picked = await CountryPickerSheet.show(context, selected: country);
    if (picked != null) onCountryChanged?.call(picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final picker = onCountryChanged != null;
    return AppTextField(
      controller: controller,
      label: floatingLabel ? label ?? l10n.phoneLabel : null,
      hint: hint ?? l10n.phoneHint,
      errorText: errorText,
      enabled: enabled,
      keyboardType: TextInputType.phone,
      validator: validator,
      onChanged: onChanged,
      prefix: _CountryPrefix(
        country: country,
        onTap: picker && enabled ? () => _pick(context) : null,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(country.maxDigits),
      ],
    );
  }
}

/// `🇮🇳 +91 ▾` at the start of the field, with a hairline divider.
class _CountryPrefix extends StatelessWidget {
  const _CountryPrefix({required this.country, this.onTap});

  final CountryDialCode country;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      button: onTap != null,
      label: l10n.phoneCountryCode(country.name, country.prefix),
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.input,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.only(left: AppSpacing.md, right: AppSpacing.sm),
          margin: const EdgeInsets.only(right: AppSpacing.sm),
          decoration: BoxDecoration(
            border: Border(right: BorderSide(color: context.colors.border)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(country.flag, style: context.textTheme.titleMedium),
              const Gap.h(AppSpacing.xs),
              Text(country.prefix, style: context.textTheme.bodyLarge?.semiBold),
              if (onTap != null) Icon(AppIcons.expandMore, size: 20, color: context.colors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

/// Searchable list of every country's calling code (India pinned first).
class CountryPickerSheet extends StatefulWidget {
  const CountryPickerSheet({required this.selected, super.key});

  final CountryDialCode selected;

  static Future<CountryDialCode?> show(BuildContext context, {required CountryDialCode selected}) {
    return AppSheets.show<CountryDialCode>(
      context,
      padded: false,
      builder: (_) => CountryPickerSheet(selected: selected),
    );
  }

  @override
  State<CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<CountryPickerSheet> {
  String _query = '';

  List<CountryDialCode> get _countries {
    final q = _query.trim().toLowerCase().replaceFirst('+', '');
    final pinned = [CountryDialCode.india, ...CountryDialCode.all.where((c) => c.iso != CountryDialCode.india.iso)];
    if (q.isEmpty) return pinned;
    return pinned
        .where((c) => c.name.toLowerCase().contains(q) || c.dialCode.startsWith(q) || c.iso.toLowerCase() == q)
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final countries = _countries;
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.85,
      child: AppSheetLayout(
        title: l10n.phoneChooseCountry,
        icon: AppIcons.phone,
        scrollable: false,
        bodyPadding: EdgeInsets.zero,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xs),
              child: AppTextField(
                hint: l10n.phoneSearchCountry,
                prefixIcon: AppIcons.search,
                autofocus: false,
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            Expanded(
              child: countries.isEmpty
                  ? Center(
                      child: Text(
                        l10n.phoneNoCountry,
                        style: context.textTheme.bodyMedium?.withColor(context.colors.textSecondary),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                      itemCount: countries.length,
                      itemBuilder: (context, i) {
                        final c = countries[i];
                        final selected = c.iso == widget.selected.iso;
                        return Semantics(
                          selected: selected,
                          child: AppListTile(
                            leading: Text(c.flag, style: context.textTheme.headlineSmall),
                            title: c.name,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  c.prefix,
                                  style: context.textTheme.bodyMedium?.semiBold.withColor(context.colors.textSecondary),
                                ),
                                if (selected) ...[
                                  const Gap.h(AppSpacing.sm),
                                  Icon(AppIcons.success, color: context.scheme.primary),
                                ],
                              ],
                            ),
                            onTap: () => Navigator.of(context).pop(c),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
