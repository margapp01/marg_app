import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/location/captured_location.dart';
import '../../../../core/media/image_picker_service.dart';
import '../../../../core/media/picked_photo.dart';
import '../../../../core/models/spiritual_choices.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/onboarding_draft.dart';
import '../controllers/auth_controller.dart';
import '../controllers/onboarding_controller.dart';
import '../states/auth_state.dart';
import '../widgets/setup/about_step.dart';
import '../widgets/setup/complete_step.dart';
import '../widgets/setup/interests_step.dart';
import '../widgets/setup/preferences_step.dart';
import '../widgets/setup/profile_step.dart';
import '../widgets/setup/setup_complete_view.dart';
import '../widgets/setup/setup_models.dart';
import '../widgets/setup/setup_stepper.dart';

/// "Complete Your Profile" — five steps: welcome (photo, name, email) → about
/// you (birthday, gender, city) → what brings you here (interests) → spiritual
/// preferences (deities, visit frequency, yatras, language) → review.
///
/// Answers live in local state, seeded from the Google profile; "Complete
/// Setup" on the review step persists everything in one pass (registration →
/// profile → location → notification defaults → complete-onboarding), then
/// shows "You're all set!" before entering the app.
class SetupPage extends ConsumerStatefulWidget {
  const SetupPage({super.key});

  @override
  ConsumerState<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends ConsumerState<SetupPage> {
  static const int _steps = 5;
  static const int _welcomeStep = 0;
  static const int _reviewStep = 4;

  final _pageController = PageController();
  int _step = 0;
  bool _completed = false;

  // ── Answers (seeded from the Google profile / existing user) ──────────────
  late final TextEditingController _nameController;
  final _mobileController = TextEditingController();
  String _email = '';
  String? _photoUrl;
  PickedPhoto? _pickedPhoto;
  String? _mobileError;
  DateTime? _dob;
  SetupGender? _gender;
  CapturedLocation? _location;
  final Set<SetupInterest> _interests = {};
  final Set<DeityChoice> _deities = {};
  VisitFrequency? _frequency;
  final Set<YatraType> _routeTypes = {};
  SetupLanguage _language = SetupLanguage.english;

  @override
  void initState() {
    super.initState();
    final auth = ref.read(authControllerProvider);
    final google = auth.googleProfile;
    final user = auth.user;

    _nameController = TextEditingController(text: user?.name ?? google?.name ?? '');
    _email = user?.email ?? google?.email ?? '';
    _photoUrl = user?.profilePhoto ?? google?.photo;
    _dob = user?.dob;
    _gender = SetupGender.fromWire(user?.gender);
    _language = SetupLanguage.fromWire(user?.preferredLanguage);

    final seeded = (user?.interests ?? const []).map(SetupInterest.fromWire).whereType<SetupInterest>();
    _interests.addAll(seeded.isEmpty ? {SetupInterest.templeVisits} : seeded);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  /// A brand-new Google account still needs its mobile number to create the
  /// Marg session — the only case that shows the mobile field and runs
  /// complete-registration.
  bool get _requiresRegistration => ref.read(authControllerProvider).status == AuthStatus.needsMobile;

  bool get _validMobile => _mobileController.text.trim().length == 10;

  /// City name for the profile, derived from the reverse geocode.
  String? get _city {
    final place = _location?.place;
    if (place == null) return null;
    if (place.city != null && place.city!.isNotEmpty) return place.city;
    return place.label.isEmpty ? null : place.label;
  }

  void _go(int step) => _pageController.animateToPage(
        step,
        duration: AppDurations.normal,
        curve: AppCurves.standard,
      );

  void _back() {
    if (_step > 0) {
      _go(_step - 1);
    } else {
      context.goNamed(RouteNames.auth);
    }
  }

  void _onPrimary() {
    switch (_step) {
      case _welcomeStep:
        if (_requiresRegistration && !_validMobile) {
          setState(() => _mobileError = AppLocalizations.of(context).suInvalidMobile);
          return;
        }
        setState(() => _mobileError = null);
        _go(_step + 1);
      case _reviewStep:
        _submit();
      default:
        _go(_step + 1);
    }
  }

  void _toggle<T>(Set<T> set, T value) => setState(() => set.contains(value) ? set.remove(value) : set.add(value));

  void _pickPhoto() {
    final l10n = AppLocalizations.of(context);
    AppSheets.actions(
      context,
      title: l10n.suPhotoTitle,
      actions: [
        SheetAction(label: l10n.suTakePhoto, icon: AppIcons.camera, onTap: () => _pickFrom(ImageSource.camera)),
        SheetAction(label: l10n.suChooseGallery, icon: AppIcons.gallery, onTap: () => _pickFrom(ImageSource.gallery)),
        if (_pickedPhoto != null)
          SheetAction(
            label: l10n.suRemovePhoto,
            icon: AppIcons.delete,
            destructive: true,
            onTap: () => setState(() => _pickedPhoto = null),
          ),
      ],
    );
  }

  Future<void> _pickFrom(ImageSource source) async {
    try {
      final photo = await ref.read(imagePickerServiceProvider).pick(source);
      if (photo != null && mounted) setState(() => _pickedPhoto = photo);
    } catch (_) {
      if (mounted) AppSnackbar.error(context, AppLocalizations.of(context).suPhotoError);
    }
  }

  Future<void> _submit() async {
    final requiresRegistration = _requiresRegistration;
    final draft = OnboardingDraft(
      name: _nameController.text.trim(),
      mobile: requiresRegistration ? '+91${_mobileController.text.trim()}' : null,
      dob: _dob,
      gender: _gender?.wire,
      city: _city,
      profilePhoto: _photoUrl,
      interests: [for (final i in _interests) i.wire],
      favoriteDeities: [for (final d in _deities) d.wire],
      visitFrequency: _frequency?.wire,
      preferredRouteTypes: [for (final r in _routeTypes) r.wire],
      preferredLanguage: _language.wire,
      notificationPreferences: SetupNotification.toPreferencesBody(SetupNotification.defaults),
      location: _location,
      pickedPhoto: _pickedPhoto,
    );

    final user = await ref
        .read(onboardingControllerProvider.notifier)
        .submit(draft, requiresRegistration: requiresRegistration);
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    if (user != null) {
      setState(() => _completed = true);
    } else {
      AppSnackbar.error(context, l10n.suSetupFailed);
    }
  }

  void _startJourney() => context.goNamed(RouteNames.home);

  List<ReviewRow> _reviewRows(AppLocalizations l10n) {
    String? joined(Iterable<String> items) => items.isEmpty ? null : items.join(', ');
    return [
      (icon: AppIcons.calendar, value: _dob == null ? null : formatSetupDate(_dob!)),
      (icon: _gender?.icon ?? AppIcons.profile, value: _gender?.localizedLabel(l10n)),
      (icon: AppIcons.location, value: _city),
      (icon: AppIcons.favorite, value: joined(_interests.map((i) => i.localizedLabel(l10n)))),
      (icon: AppIcons.temple, value: joined(_deities.map((d) => d.localizedLabel(l10n)))),
      (icon: AppIcons.timer, value: _frequency?.localizedLabel(l10n)),
      (icon: AppIcons.route, value: joined(_routeTypes.map((r) => r.localizedLabel(l10n))) ?? l10n.suRouteNotSure),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final submitting = ref.watch(onboardingControllerProvider).isLoading;
    final size = MediaQuery.sizeOf(context);

    if (_completed) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _startJourney();
        },
        child: Scaffold(
          backgroundColor: context.colors.splashCanvas,
          body: SafeArea(child: SetupCompleteView(onStart: _startJourney)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.colors.splashCanvas,
      body: Stack(
        children: [
          // The temple skyline from the sign-in screen, faded in behind the
          // primary action.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: size.height * 0.2,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.55,
                child: ShaderMask(
                  blendMode: BlendMode.dstIn,
                  shaderCallback: (rect) => const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.white],
                    stops: [0.0, 0.6],
                  ).createShader(rect),
                  child: Image.asset(BrandAssets.loginOverlay, fit: BoxFit.cover, alignment: Alignment.bottomCenter),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.xs, AppSpacing.xs, AppSpacing.xs, 0),
                  child: Row(
                    children: [
                      AppIconButton(icon: AppIcons.back, tooltip: l10n.suBack, onPressed: submitting ? null : _back),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '${l10n.suStep} ${_step + 1}',
                                style: context.textTheme.labelLarge?.semiBold.withColor(context.scheme.secondary),
                              ),
                              TextSpan(
                                text: ' ${l10n.suOf} $_steps',
                                style: context.textTheme.labelLarge?.copyWith(color: context.colors.textSecondary),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      // Balances the back button so the label stays centred.
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.huge3),
                  child: SetupProgress(current: _step, total: _steps),
                ),
                const Gap(AppSpacing.sm),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (i) => setState(() => _step = i),
                    children: [
                      WelcomeStep(
                        nameController: _nameController,
                        email: _email,
                        photoUrl: _photoUrl,
                        pickedPhoto: _pickedPhoto,
                        showMobile: _requiresRegistration,
                        mobileController: _mobileController,
                        mobileError: _mobileError,
                        onEditPhoto: _pickPhoto,
                      ),
                      AboutStep(
                        dob: _dob,
                        onPickDob: (d) => setState(() => _dob = d),
                        gender: _gender,
                        onPickGender: (g) => setState(() => _gender = g),
                        location: _location,
                        onLocation: (loc) => setState(() => _location = loc),
                      ),
                      InterestsStep(selected: _interests, onToggle: (i) => _toggle(_interests, i)),
                      SpiritualStep(
                        deities: _deities,
                        onToggleDeity: (d) => _toggle(_deities, d),
                        frequency: _frequency,
                        onFrequency: (f) => setState(() => _frequency = f),
                        routeTypes: _routeTypes,
                        onToggleRouteType: (r) => _toggle(_routeTypes, r),
                        onClearRouteTypes: () => setState(_routeTypes.clear),
                        language: _language,
                        onLanguage: (l) => setState(() => _language = l),
                      ),
                      ReviewStep(
                        name: _nameController.text.trim(),
                        email: _email,
                        photoUrl: _photoUrl,
                        pickedPhoto: _pickedPhoto,
                        rows: _reviewRows(l10n),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: AppSpacing.screenAll,
                  child: AppButton(
                    label: _step == _reviewStep ? l10n.suCompleteSetup : l10n.suContinue,
                    trailingIcon: AppIcons.arrowForward,
                    busy: submitting,
                    onPressed: _onPrimary,
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
