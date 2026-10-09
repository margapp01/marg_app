import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../shared/design_system.dart';
import '../../data/repository/profile_repository.dart';
import '../../domain/entities/profile.dart';
import '../controllers/profile_controllers.dart';
import '../widgets/profile_widgets.dart';

/// Screen 2 — Edit Profile. Editable: name, DOB, gender, city, language, avatar.
/// Read-only: email (Google-managed) and mobile (set once at registration).
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
  late final _city = TextEditingController(text: widget.profile.city ?? '');
  late final _phone = TextEditingController(text: widget.profile.phone ?? '—');
  late DateTime? _dob = widget.profile.dob;
  late ProfileGender? _gender = ProfileGender.fromWire(widget.profile.gender);
  late String _language = widget.profile.preferredLanguage;
  bool _saving = false;
  bool _uploading = false;

  @override
  void dispose() {
    _name.dispose();
    _city.dispose();
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

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _saving = true);
    try {
      await ref.read(profileRepositoryProvider).updateProfile(
            name: _name.text.trim(),
            dob: _dob,
            gender: _gender?.wire,
            city: _city.text.trim(),
            preferredLanguage: _language,
          );
      ref.invalidate(profileProvider);
      if (mounted) {
        AppSnackbar.success(context, l10n.pfSaved);
        context.pop();
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
    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(title: Text(l10n.pfEditProfile)),
      bottomNavigationBar: BottomActionBar(
        child: AppButton.primary(label: l10n.pfSaveChanges, busy: _saving, onPressed: _saving ? null : _save),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: AppSpacing.screenAll,
          children: [
            _AvatarEditor(
              imageUrl: widget.profile.profilePhoto,
              name: widget.profile.name,
              uploading: _uploading,
              onEdit: _pickAvatar,
            ).fadeIn(),
            const Gap(AppSpacing.xl),
            SettingsGroup(
              title: l10n.pfPersonalDetails,
              padding: AppSpacing.allMd,
              children: [
                Column(
                  children: [
                    AppTextField(
                      controller: _name,
                      label: l10n.pfFullName,
                      prefixIcon: AppIcons.profile,
                      validator: (v) => (v == null || v.trim().isEmpty) ? l10n.pfNameRequired : null,
                    ),
                    const Gap(AppSpacing.md),
                    DateField(
                      value: _dob,
                      label: l10n.pfDob,
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                      onChanged: (d) => setState(() => _dob = d),
                    ),
                    const Gap(AppSpacing.md),
                    AppDropdown<ProfileGender>(
                      label: l10n.pfGender,
                      prefixIcon: AppIcons.profile,
                      value: _gender,
                      items: [for (final g in ProfileGender.values) AppDropdownItem(value: g, label: genderLabel(l10n, g))],
                      onChanged: (g) => setState(() => _gender = g),
                    ),
                    const Gap(AppSpacing.md),
                    AppTextField(controller: _city, label: l10n.pfCity, prefixIcon: AppIcons.location),
                  ],
                ),
              ],
            ),
            const Gap(AppSpacing.xl),
            SettingsGroup(
              title: l10n.pfGroupAccount,
              padding: AppSpacing.allMd,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextField(
                      controller: _phone,
                      label: l10n.pfMobile,
                      prefixIcon: AppIcons.phone,
                      readOnly: true,
                      helperText: l10n.pfMobileLocked,
                    ),
                    const Gap(AppSpacing.md),
                    AppDropdown<String>(
                      label: l10n.pfLanguage,
                      prefixIcon: AppIcons.language,
                      value: _language,
                      items: [
                        AppDropdownItem(value: 'EN', label: l10n.pfLanguageEnglish),
                        AppDropdownItem(value: 'HI', label: l10n.pfLanguageHindi),
                      ],
                      onChanged: (v) => setState(() => _language = v ?? 'EN'),
                    ),
                    const Gap(AppSpacing.md),
                    Row(
                      children: [
                        Icon(AppIcons.mail, size: 16, color: context.colors.textSecondary),
                        const Gap.h(AppSpacing.sm),
                        Expanded(
                          child: Text(
                            '${widget.profile.email ?? ''} · ${l10n.pfEmailLocked}',
                            style: context.caption.copyWith(color: context.colors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
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
