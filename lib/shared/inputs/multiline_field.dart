import 'package:flutter/material.dart';

import '../components/app_text_field.dart';

/// Multi-line text input (reviews, notes, descriptions). A thin preset over
/// [AppTextField] that grows between [minLines] and [maxLines].
class MultilineField extends StatelessWidget {
  const MultilineField({
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.minLines = 3,
    this.maxLines = 6,
    this.maxLength,
    this.enabled = true,
    this.validator,
    this.onChanged,
    super.key,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final int minLines;
  final int maxLines;
  final int? maxLength;
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
      minLines: minLines,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: TextInputType.multiline,
      textCapitalization: TextCapitalization.sentences,
      validator: validator,
      onChanged: onChanged,
    );
  }
}
