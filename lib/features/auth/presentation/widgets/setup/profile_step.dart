import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../app/localization/app_localizations.dart';
import '../../../../../core/location/captured_location.dart';
import '../../../../../core/media/picked_photo.dart';
import '../../../../../core/models/country_dial_code.dart';
import '../../../../../shared/design_system.dart';
import 'setup_common.dart';

/// Step 1 — "Welcome to Marg": the photo (inside a mandala ring), name, the
/// Google-owned email, an optional mobile number (any country) and the city
/// from the device location. Everything after this step can be skipped.
class WelcomeStep extends StatelessWidget {
  const WelcomeStep({
    required this.nameController,
    required this.email,
    required this.mobileController,
    required this.country,
    required this.onCountryChanged,
    required this.location,
    required this.onLocation,
    required this.onEditPhoto,
    this.photoUrl,
    this.pickedPhoto,
    this.mobileError,
    super.key,
  });

  final TextEditingController nameController;
  final String email;
  final TextEditingController mobileController;
  final CountryDialCode country;
  final ValueChanged<CountryDialCode> onCountryChanged;
  final String? mobileError;
  final CapturedLocation? location;
  final ValueChanged<CapturedLocation> onLocation;
  final String? photoUrl;

  /// A just-picked avatar shown as an instant preview before it's uploaded.
  final PickedPhoto? pickedPhoto;

  /// Opens the photo source chooser (owned by the parent, which has the picker).
  final VoidCallback onEditPhoto;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: AppSpacing.screenAll,
      children: [
        SetupHeader(title: l10n.suWelcomeTitle, subtitle: l10n.suWelcomeSubtitle),
        const Gap(AppSpacing.lg),
        Center(
          child: _MandalaAvatar(picked: pickedPhoto, photoUrl: photoUrl, onTap: onEditPhoto),
        ),
        const Gap(AppSpacing.lg),
        LabeledField(
          label: l10n.suFullName,
          child: AppTextField(
            controller: nameController,
            prefixIcon: AppIcons.profile,
            textCapitalization: TextCapitalization.words,
          ),
        ),
        const Gap(AppSpacing.lg),
        LabeledField(
          label: l10n.suEmail,
          child: AppTextField(initialValue: email, enabled: false, prefixIcon: AppIcons.mail),
        ),
        const Gap(AppSpacing.lg),
        LabeledField(
          label: l10n.suMobileNumber,
          hint: l10n.suOptional,
          child: PhoneField(
            controller: mobileController,
            country: country,
            onCountryChanged: onCountryChanged,
            floatingLabel: false,
            errorText: mobileError,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xs, left: AppSpacing.xxs),
          child: Text(l10n.suMobileHint, style: context.textTheme.bodySmall?.withColor(context.colors.textSecondary)),
        ),
        const Gap(AppSpacing.lg),
        LabeledField(
          label: l10n.suCityLocation,
          child: CityField(value: location?.place?.label, gpsFirst: true, onPicked: onLocation),
        ),
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xs, left: AppSpacing.xxs),
          child: Text(l10n.suLocationHint, style: context.textTheme.bodySmall?.withColor(context.colors.textSecondary)),
        ),
      ],
    );
  }
}

/// The avatar inside a soft golden mandala, with an edit badge. Shows the
/// just-picked image, else the Google photo, else an "Add Photo" prompt.
class _MandalaAvatar extends StatelessWidget {
  const _MandalaAvatar({required this.onTap, this.picked, this.photoUrl});

  final PickedPhoto? picked;
  final String? photoUrl;
  final VoidCallback onTap;

  static const double _size = 184;
  static const double _photo = 124;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final Widget photo;
    if (picked != null) {
      photo = Image.memory(picked!.bytes, fit: BoxFit.cover, gaplessPlayback: true);
    } else if (photoUrl != null && photoUrl!.isNotEmpty) {
      photo = AppNetworkImage(url: photoUrl!);
    } else {
      photo = ColoredBox(
        color: context.colors.templeSand,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(AppIcons.camera, size: 30, color: context.colors.textSecondary),
            const Gap(AppSpacing.xxs),
            Text(l10n.suAddPhoto, style: context.textTheme.labelMedium?.copyWith(color: context.colors.textSecondary)),
          ],
        ),
      );
    }

    return Semantics(
      button: true,
      label: l10n.suChangePhoto,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox.square(
          dimension: _size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size.square(_size),
                painter: _MandalaPainter(color: context.colors.gold),
              ),
              Container(
                width: _photo,
                height: _photo,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: context.colors.card, width: 4),
                  boxShadow: AppShadows.md,
                ),
                child: ClipOval(child: photo),
              ),
              Positioned(
                right: (_size - _photo) / 2 - AppSpacing.xxs,
                bottom: (_size - _photo) / 2 - AppSpacing.xxs,
                child: Container(
                  padding: AppSpacing.allSm,
                  decoration: BoxDecoration(
                    color: context.scheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: context.colors.card, width: 2),
                  ),
                  child: Icon(AppIcons.edit, size: 16, color: context.scheme.onPrimary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Two fine rings with a circle of lotus petals between them.
class _MandalaPainter extends CustomPainter {
  const _MandalaPainter({required this.color});

  final Color color;

  static const int _petals = 24;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.width / 2;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = color.withValues(alpha: 0.35);
    final fill = Paint()..color = color.withValues(alpha: 0.10);

    canvas.drawCircle(center, r * 0.98, stroke);
    canvas.drawCircle(center, r * 0.74, stroke);
    for (var i = 0; i < _petals; i++) {
      final angle = 2 * math.pi * i / _petals;
      canvas
        ..save()
        ..translate(center.dx, center.dy)
        ..rotate(angle);
      final petal = Rect.fromCenter(center: Offset(0, -r * 0.86), width: r * 0.12, height: r * 0.2);
      canvas
        ..drawOval(petal, fill)
        ..drawOval(petal, stroke)
        ..restore();
    }
  }

  @override
  bool shouldRepaint(_MandalaPainter oldDelegate) => oldDelegate.color != color;
}
