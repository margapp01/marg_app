import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_icons.dart';
import '../components/app_text_field.dart';

/// Phone number input with a fixed dial-code prefix (defaults to India, +91)
/// and digits-only entry. Kept dependency-free; a country picker can be added
/// later without changing call sites.
class PhoneField extends StatelessWidget {
  const PhoneField({
    this.controller,
    this.dialCode = '+91 ',
    this.label = 'Phone number',
    this.hint = '10-digit mobile number',
    this.maxDigits = 10,
    this.errorText,
    this.enabled = true,
    this.validator,
    this.onChanged,
    super.key,
  });

  final TextEditingController? controller;
  final String dialCode;
  final String label;
  final String? hint;
  final int maxDigits;
  final String? errorText;
  final bool enabled;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      label: label,
      hint: hint,
      errorText: errorText,
      enabled: enabled,
      keyboardType: TextInputType.phone,
      maxLength: maxDigits,
      validator: validator,
      onChanged: onChanged,
      prefixIcon: AppIcons.phone,
      prefixText: dialCode,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(maxDigits),
      ],
    );
  }
}
