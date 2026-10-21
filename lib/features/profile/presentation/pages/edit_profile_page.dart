import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/constants/app_constants.dart';
import '../../../../app/localization/app_localizations.dart';
import '../../../../core/location/captured_location.dart';
import '../../../../core/location/location_api.dart';
import '../../../../core/models/country_dial_code.dart';
import '../../../../core/utils/age.dart';
import '../../../../shared/design_system.dart';
import '../../../explore/presentation/controllers/explore_controllers.dart';
import '../../../home/presentation/controllers/home_controller.dart';
import '../../data/repository/profile_repository.dart';
import '../../domain/entities/profile.dart';
import '../../domain/entities/profile_completion.dart';
import '../controllers/profile_controllers.dart';
import '../widgets/profile_widgets.dart';

/// Screen 2 — Edit Profile. Editable: name, DOB, gender, city, mobile (any
/// country, optional), language, avatar. Read-only: email (Google-managed).
class EditProfilePage extends ConsumerWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(profileProvider);
    return async.when(
      loading: () => Scaffold(appBar: AppBar(title: Text(l10n.pfEditProfile)), body: const LoadingView()),
      error: (_, _) => Scaffold(appBar: AppBar(title: Text(l10n.pfEditProfile)), body: ErrorView(title: l10n.pfErrorTitle, message: l10n.pfErrorBody, onRetry: () => ref.invalidate(profileProvider))),
      data: (profile) => _EditForm(profile: profile),
    );
  }
}

class _EditForm extends ConsumerStatefulWidget {
  const _EditForm({required this.profile});
  final Profile profile;
  @override
  ConsumerState<_EditForm> createState() => _EditFormState();
}

class _EditFormState extends ConsumerState<_EditForm> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.profile.name ?? '');
  late final _phoneParts = CountryDialCode.parse(widget.profile.phone, preferred: CountryDialCode.deviceDefault);
  late CountryDialCode _country = _phoneParts?.country ?? CountryDialCode.deviceDefault;
  late final _phone = TextEditingController(text: _phoneParts?.digits ?? '');
  String? _phoneError;
  late DateTime? _dob = widget.profile.dob;
  late ProfileGender? _gender = ProfileGender.fromWire(widget.profile.gender);
  late String _language = widget.profile.preferredLanguage;

  /// A newly detected / searched city; saved (with its coordinates) on Save.
  CapturedLocation? _location;
  bool _saving = false;
  bool _uploading = false;

  /// A freshly picked location's place (null when it couldn't be named), else
  /// the saved city.
  String? get _cityLabel => _location != null ? _location!.place?.label : widget.profile.city;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1024, imageQuality: 85);
    if (picked == null) return;
    setState(() => _uploading = true);
    try {
      final bytes = await picked.readAsBytes();
      final mime = picked.mimeType ?? (picked.name.toLowerCase().endsWith('.png') ? 'image/png' : 'image/jpeg');
      await ref.read(profileRepositoryProvider).uploadAvatar(bytes: bytes, fileName: picked.name, mimeType: mime);
      ref.invalidate(profileProvider);
      if (mounted) AppSnackbar.success(context, AppLocalizations.of(context).pfPhotoUpdated);
    } catch (_) {
      if (mounted) AppSnackbar.error(context, AppLocalizations.of(context).pfPhotoFailed);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  /// What to send for the mobile: unchanged → null (omitted), cleared → ''
  /// (removes it), otherwise the new E.164 number.
  String? get _phonePatch {
    final digits = _phone.text.trim();
    final next = digits.isEmpty ? null : _country.e164(digits);
    if (next == widget.profile.phone) return null;
    return next ?? '';
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final l10n = AppLocalizations.of(context);
    final digits = _phone.text.trim();
    if (digits.isNotEmpty && !_country.accepts(digits)) {
      setState(() => _phoneError = l10n.suInvalidMobile);
      return;
    }
    setState(() => _phoneError = null);
    final dob = _dob;
    if (dob != null && !isAtLeastAge(dob, AppConstants.minAccountAge)) {
      AppSnackbar.error(context, l10n.suAgeRestricted(AppConstants.minAccountAge));
      return;
    }
    setState(() => _saving = true);
    try {
      final location = _location;
      await ref.read(profileRepositoryProvider).updateProfile(
            name: _name.text.trim(),
            dob: _dob,
            gender: _gender?.wire,
            city: location?.place?.city ?? location?.place?.label,
            preferredLanguage: _language,
            phone: _phonePatch,
          );
      if (location != null) {
        // The city's (or device's) coordinates power Nearby Temples.
        try {
          await ref.read(locationApiProvider).updateMyLocation(location);
        } catch (_) {/* best-effort; the device copy still drives Home */}
        ref
          ..invalidate(homeControllerProvider)
          ..invalidate(exploreLocationProvider);
      }
      ref.invalidate(profileProvider);
      if (mounted) {
        AppSnackbar.success(context, l10n.pfSaved);
        context.pop();
      }
    } on DioException catch (e) {
      if (!mounted) return;
      if (e.response?.statusCode == 409) {
        setState(() => _phoneError = l10n.suMobileTaken);
      } else {
        AppSnackbar.error(context, l10n.pfSaveFailed);
      }
    } catch (_) {
      if (mounted) AppSnackbar.error(context, l10n.pfSaveFailed);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final completion = ProfileCompletion.of(widget.profile);
    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(title: Text(l10n.pfEditProfile), backgroundColor: context.palette.heroCream),
      bottomNavigationBar: BottomActionBar(
        child: AppButton.primary(label: l10n.pfSaveChanges, icon: AppIcons.check, busy: _saving, onPressed: _saving ? null : _save),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
          children: [
            _Header(
              profile: widget.profile,
              completion: completion,
              uploading: _uploading,
              onEditPhoto: _pickAvatar,
            ),
            Padding(
              padding: AppSpacing.screenH,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Gap(AppSpacing.lg),
                  _Section(
                    icon: AppIcons.profile,
                    title: l10n.pfAboutYou,
                    children: [
                      AppTextField(
                        controller: _name,
                        label: l10n.pfFullName,
                        prefixIcon: AppIcons.profile,
                        textCapitalization: TextCapitalization.words,
                        validator: (v) => (v == null || v.trim().isEmpty) ? l10n.pfNameRequired : null,
                      ),
                      DateField(
                        value: _dob,
                        label: l10n.pfDob,
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                        onChanged: (d) => setState(() => _dob = d),
                      ),
                      _FieldLabel(l10n.pfGender),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final g in ProfileGender.values) ...[
                            if (g != ProfileGender.values.first) const Gap.h(AppSpacing.xs),
                            Expanded(
                              child: ChoiceTile(
                                icon: _genderIcon(g),
                                label: genderLabel(l10n, g),
                                selected: _gender == g,
                                onTap: () => setState(() => _gender = g),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  _Section(
                    icon: AppIcons.location,
                    title: l10n.pfYourCity,
                    subtitle: l10n.pfYourCityHint,
                    children: [
                      CityField(value: _cityLabel, onPicked: (loc) => setState(() => _location = loc)),
                    ],
                  ),
                  _Section(
                    icon: AppIcons.phone,
                    title: l10n.pfContact,
                    children: [
                      PhoneField(
                        controller: _phone,
                        country: _country,
                        onCountryChanged: (c) => setState(() {
                          _country = c;
                          _phoneError = null;
                        }),
                        label: l10n.pfMobile,
                        errorText: _phoneError,
                      ),
                      _LockedRow(icon: AppIcons.mail, value: widget.profile.email ?? '', note: l10n.pfEmailLocked),
                    ],
                  ),
                  _Section(
                    icon: AppIcons.language,
                    title: l10n.pfLanguage,
                    children: [
                      Row(
                        children: [
                          for (final (code, label) in [('EN', l10n.pfLanguageEnglish), ('HI', l10n.pfLanguageHindi)]) ...[
                            if (code != 'EN') const Gap.h(AppSpacing.sm),
                            Expanded(
                              child: ChoiceTile(
                                icon: AppIcons.language,
                                label: label,
                                selected: _language == code,
                                onTap: () => setState(() => _language = code),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static IconData _genderIcon(ProfileGender g) => switch (g) {
        ProfileGender.male => AppIcons.male,
        ProfileGender.female => AppIcons.female,
        ProfileGender.other => AppIcons.genderOther,
        ProfileGender.preferNotToSay => AppIcons.preferNotToSay,
      };
}

/// The page header: the avatar editor on a light wash with the skyline, the
/// devotee's name and how complete their profile is.
class _Header extends StatelessWidget {
  const _Header({required this.profile, required this.completion, required this.uploading, required this.onEditPhoto});

  final Profile profile;
  final ProfileCompletion completion;
  final bool uploading;
  final VoidCallback onEditPhoto;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final saffron = context.scheme.primary;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [context.palette.heroCream, context.scheme.surface],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 0),
      child: Column(
        children: [
          _AvatarEditor(imageUrl: profile.profilePhoto, name: profile.name, uploading: uploading, onEdit: onEditPhoto).fadeIn(),
          if (profile.name != null) Text(profile.name!, style: context.displayText.titleLarge, textAlign: TextAlign.center),
          const Gap(AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: context.colors.card,
              borderRadius: AppRadius.card,
              border: Border.all(color: (completion.isComplete ? context.colors.success : saffron).withValues(alpha: 0.35)),
            ),
            child: Row(
              children: [
                Icon(
                  completion.isComplete ? AppIcons.verified : AppIcons.trending,
                  size: 20,
                  color: completion.isComplete ? context.colors.success : saffron,
                ),
                const Gap.h(AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.pfCompletionTitle(completion.percent), style: context.textTheme.labelLarge?.semiBold),
                      const Gap(AppSpacing.xxs),
                      AppLinearProgress(
                        value: completion.percent / 100,
                        color: completion.isComplete ? context.colors.success : saffron,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A titled card of fields with an icon badge.
class _Section extends StatelessWidget {
  const _Section({required this.icon, required this.title, required this.children, this.subtitle});

  final IconData icon;
  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final navy = context.scheme.secondary;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: AppCard(
        padding: AppSpacing.allLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: AppSpacing.allSm,
                  decoration: BoxDecoration(color: navy.withValues(alpha: 0.08), shape: BoxShape.circle),
                  child: Icon(icon, size: 18, color: navy),
                ),
                const Gap.h(AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: context.textTheme.titleSmall?.semiBold.withColor(navy)),
                      if (subtitle != null) Text(subtitle!, style: context.caption.copyWith(color: context.colors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(AppSpacing.md),
            for (final (i, child) in children.indexed) ...[
              if (i > 0) const Gap(AppSpacing.md),
              child,
            ],
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: context.textTheme.labelLarge?.withColor(context.colors.textSecondary));
}

/// A read-only value with a lock (the Google-managed email).
class _LockedRow extends StatelessWidget {
  const _LockedRow({required this.icon, required this.value, required this.note});
  final IconData icon;
  final String value;
  final String note;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(color: context.scheme.surfaceContainer, borderRadius: AppRadius.input),
      child: Row(
        children: [
          Icon(icon, size: 20, color: context.colors.textSecondary),
          const Gap.h(AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.textTheme.bodyMedium),
                Text(note, style: context.caption.copyWith(color: context.colors.textSecondary)),
              ],
            ),
          ),
          Icon(AppIcons.lock, size: 16, color: context.colors.textDisabled),
        ],
      ),
    );
  }
}

/// The avatar in its gold ring with a navy camera badge, and a "Change photo"
/// link underneath.
class _AvatarEditor extends StatelessWidget {
  const _AvatarEditor({required this.imageUrl, required this.name, required this.uploading, required this.onEdit});

  final String? imageUrl;
  final String? name;
  final bool uploading;
  final VoidCallback onEdit;

  static const double _badgeIcon = 18;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final navy = context.scheme.secondary;
    final onNavy = context.scheme.onSecondary;
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            GoldRingAvatar(imageUrl: imageUrl, name: name),
            Positioned(
              right: 0,
              bottom: 0,
              child: Material(
                color: navy,
                shape: CircleBorder(side: BorderSide(color: context.colors.card, width: 2)),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: uploading ? null : onEdit,
                  child: Padding(
                    padding: AppSpacing.allSm,
                    child: uploading
                        ? SizedBox.square(dimension: _badgeIcon, child: CircularProgressIndicator(strokeWidth: 2, color: onNavy))
                        : Icon(AppIcons.camera, size: _badgeIcon, color: onNavy),
                  ),
                ),
              ),
            ),
          ],
        ),
        TextButton(onPressed: uploading ? null : onEdit, child: Text(l10n.pfChangePhoto)),
      ],
    );
  }
}
