import 'package:flutter/material.dart';

import '../../../../../app/localization/app_localizations.dart';
import '../../../../../core/location/captured_location.dart';
import '../../../../../shared/design_system.dart';
import 'location_step.dart';
import 'setup_common.dart';
import 'setup_models.dart';

/// Step 2 — "Tell Us About You": date of birth, gender and city.
class AboutStep extends StatelessWidget {
  const AboutStep({
    required this.dob,
    required this.onPickDob,
    this.dobError,
    required this.gender,
    required this.onPickGender,
    this.genderError,
    required this.location,
    required this.onLocation,
    super.key,
  });

  final DateTime? dob;
  final ValueChanged<DateTime> onPickDob;

  /// Validation message under the date field (missing or under-age).
  final String? dobError;
  final SetupGender? gender;
  final ValueChanged<SetupGender> onPickGender;

  /// Validation message under the gender choices (none picked).
  final String? genderError;
  final CapturedLocation? location;
  final ValueChanged<CapturedLocation> onLocation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dobText = dob == null ? '' : formatSetupDate(dob!);
    return ListView(
      padding: AppSpacing.screenAll,
      children: [
        SetupHeader(title: l10n.suAboutTitle, subtitle: l10n.suAboutSubtitle),
        const Gap(AppSpacing.xl),
        LabeledField(
          label: l10n.suDateOfBirth,
          child: AppTextField(
            key: ValueKey(dobText),
            initialValue: dobText,
            hint: l10n.suSelectDob,
            errorText: dobError,
            readOnly: true,
            prefixIcon: AppIcons.calendar,
            suffixIcon: AppIcons.expandMore,
            onTap: () async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate: dob ?? DateTime(now.year - 25),
                firstDate: DateTime(now.year - 100),
                lastDate: now,
              );
              if (picked != null) onPickDob(picked);
            },
          ),
        ),
        const Gap(AppSpacing.xl),
        LabeledField(
          label: l10n.suGender,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final g in SetupGender.values) ...[
                    Expanded(
                      child: ChoiceTile(
                        icon: g.icon,
                        label: g.localizedLabel(l10n),
                        selected: gender == g,
                        onTap: () => onPickGender(g),
                      ),
                    ),
                    if (g != SetupGender.values.last) const Gap.h(AppSpacing.sm),
                  ],
                ],
              ),
              if (genderError != null) ...[
                const Gap(AppSpacing.xs),
                Text(genderError!, style: context.textTheme.bodySmall?.withColor(context.scheme.error)),
              ],
            ],
          ),
        ),
        const Gap(AppSpacing.xl),
        LabeledField(
          label: l10n.suCityLocation,
          child: CityLocationField(captured: location, onCaptured: onLocation),
        ),
      ],
    );
  }
}

const List<String> _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

/// "15 Aug 1995" — the onboarding date format (form + review).
String formatSetupDate(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';
