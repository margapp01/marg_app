import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/theme/app_icons.dart';
import '../components/app_text_field.dart';

/// A read-only [AppTextField] that opens the platform date picker on tap and
/// shows the chosen date. Reports selections via [onChanged].
class DateField extends StatelessWidget {
  const DateField({
    required this.value,
    required this.onChanged,
    this.label = 'Date',
    this.hint,
    this.firstDate,
    this.lastDate,
    this.enabled = true,
    this.dateFormat,
    super.key,
  });

  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final String? label;
  final String? hint;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool enabled;

  /// Defaults to `d MMM yyyy` (e.g. 14 Jul 2026).
  final DateFormat? dateFormat;

  @override
  Widget build(BuildContext context) {
    final format = dateFormat ?? DateFormat('d MMM yyyy');
    final controller = TextEditingController(
      text: value == null ? '' : format.format(value!),
    );
    return AppTextField(
      controller: controller,
      label: label,
      hint: hint,
      enabled: enabled,
      readOnly: true,
      prefixIcon: AppIcons.calendar,
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? now,
          firstDate: firstDate ?? DateTime(now.year - 100),
          lastDate: lastDate ?? DateTime(now.year + 5),
        );
        if (picked != null) onChanged(picked);
      },
    );
  }
}
