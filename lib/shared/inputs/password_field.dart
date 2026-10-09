import 'package:flutter/material.dart';

import '../../app/theme/app_icons.dart';
import '../components/app_text_field.dart';

/// Password input built on [AppTextField] with an obscure/reveal toggle.
class PasswordField extends StatefulWidget {
  const PasswordField({
    this.controller,
    this.label = 'Password',
    this.hint,
    this.errorText,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    super.key,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: widget.controller,
      label: widget.label,
      hint: widget.hint,
      errorText: widget.errorText,
      obscureText: _obscured,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: widget.textInputAction,
      prefixIcon: AppIcons.lock,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      suffix: IconButton(
        tooltip: _obscured ? 'Show password' : 'Hide password',
        icon: Icon(_obscured ? AppIcons.visibility : AppIcons.visibilityOff),
        onPressed: () => setState(() => _obscured = !_obscured),
      ),
    );
  }
}
