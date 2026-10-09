import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

import '../../app/theme/app_radius.dart';
import '../../core/extensions/context_extensions.dart';

/// One-time-code entry (SMS / email verification) built on [Pinput], themed
/// from the design system. Emits [onCompleted] when all [length] digits are in.
class OtpField extends StatelessWidget {
  const OtpField({
    this.controller,
    this.length = 6,
    this.autofocus = true,
    this.enabled = true,
    this.errorText,
    this.onCompleted,
    this.onChanged,
    super.key,
  });

  final TextEditingController? controller;
  final int length;
  final bool autofocus;
  final bool enabled;
  final String? errorText;
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final base = PinTheme(
      width: 52,
      height: 56,
      textStyle: context.textTheme.titleLarge,
      decoration: BoxDecoration(
        color: context.scheme.surfaceContainerHighest,
        borderRadius: AppRadius.control,
        border: Border.all(color: context.colors.border),
      ),
    );
    return Pinput(
      controller: controller,
      length: length,
      autofocus: autofocus,
      enabled: enabled,
      onCompleted: onCompleted,
      onChanged: onChanged,
      defaultPinTheme: base,
      focusedPinTheme: base.copyDecorationWith(
        border: Border.all(color: context.scheme.primary, width: 1.6),
      ),
      submittedPinTheme: base.copyDecorationWith(
        color: context.scheme.primaryContainer,
        border: Border.all(color: context.scheme.primary),
      ),
      errorPinTheme: base.copyDecorationWith(
        border: Border.all(color: context.scheme.error, width: 1.6),
      ),
      forceErrorState: errorText != null,
      errorText: errorText,
    );
  }
}
