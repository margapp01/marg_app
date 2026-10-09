import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_spacing.dart';

/// The canonical text input. Decoration comes from the theme's
/// [InputDecorationTheme]; this wrapper keeps labels, validation, prefix/suffix
/// icons, multiline, disabled and loading states uniform.
///
/// Built on [TextFormField] so it validates inside a [Form]. For specialised
/// inputs use the `inputs/` widgets (password, OTP, dropdown, date, phone),
/// which compose this.
class AppTextField extends StatelessWidget {
  const AppTextField({
    this.controller,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.initialValue,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.loading = false,
    this.autofocus = false,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.prefixIcon,
    this.prefixText,
    this.suffixIcon,
    this.suffix,
    this.focusNode,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    super.key,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final String? initialValue;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;

  /// Shows a trailing spinner (e.g. async availability check) and takes
  /// precedence over [suffixIcon]/[suffix].
  final bool loading;
  final bool autofocus;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final int maxLines;
  final int? minLines;
  final int? maxLength;
  final IconData? prefixIcon;

  /// Fixed text shown before the input (e.g. a phone dial code).
  final String? prefixText;
  final IconData? suffixIcon;
  final Widget? suffix;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      focusNode: focusNode,
      obscureText: obscureText,
      enabled: enabled,
      readOnly: readOnly,
      autofocus: autofocus,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      maxLines: obscureText ? 1 : maxLines,
      minLines: minLines,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helperText,
        errorText: errorText,
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
        prefixText: prefixText,
        suffixIcon: _suffix(),
      ),
    );
  }

  Widget? _suffix() {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: SizedBox.square(
          dimension: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    if (suffix != null) return suffix;
    if (suffixIcon != null) return Icon(suffixIcon);
    return null;
  }
}
