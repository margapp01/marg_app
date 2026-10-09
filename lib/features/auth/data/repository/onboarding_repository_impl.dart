import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/auth_user.dart';
import '../../domain/entities/onboarding_draft.dart';
import '../../domain/repository/auth_repository.dart';
import '../../domain/repository/onboarding_repository.dart';
import '../datasource/onboarding_remote_datasource.dart';
import '../datasource/profile_photo_datasource.dart';
import 'auth_repository_impl.dart';

/// Orchestrates the onboarding submit. Registration (mobile → Marg tokens) is
/// delegated to [AuthRepository]; once a session exists, the `/my/*` calls run
/// through the authenticated Dio.
class OnboardingRepositoryImpl implements OnboardingRepository {
  OnboardingRepositoryImpl({
    required AuthRepository auth,
    required OnboardingRemoteDataSource remote,
    required ProfilePhotoDataSource photo,
  })  : _auth = auth,
        _remote = remote,
        _photo = photo;

  final AuthRepository _auth;
  final OnboardingRemoteDataSource _remote;
  final ProfilePhotoDataSource _photo;

  @override
  Future<AuthUser> submit(
    OnboardingDraft draft, {
    required bool requiresRegistration,
  }) async {
    // 1. A brand-new Google account has no Marg session yet — attaching the
    //    mobile creates the account and stores the token pair.
    if (requiresRegistration) {
      await _auth.completeRegistration(
        mobile: draft.mobile!,
        name: draft.name,
        profilePhoto: draft.profilePhoto,
      );
    }

    // 2. Upload a newly-picked avatar (best-effort — a storage hiccup must not
    //    block onboarding; we fall back to the Google photo URL).
    final patch = draft.profilePatch();
    if (draft.pickedPhoto != null) {
      try {
        patch['profilePhoto'] = await _photo.upload(draft.pickedPhoto!);
      } catch (_) {/* keep the existing profilePhoto (if any) */}
    }

    // 3. Persist the collected profile, location and preferences.
    await _remote.updateProfile(patch);
    if (draft.location != null) {
      await _remote.updateLocation(draft.location!.toJson());
    }
    await _remote.updatePreferences(draft.notificationPreferences);

    // 4. Stamp completion, then read back the finalised user.
    await _remote.completeOnboarding();
    final user = await _auth.currentUser();
    if (user == null) {
      throw StateError('Onboarding finished but the session was lost.');
    }
    return user;
  }
}

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  return OnboardingRepositoryImpl(
    auth: ref.watch(authRepositoryProvider),
    remote: ref.watch(onboardingRemoteDataSourceProvider),
    photo: ref.watch(profilePhotoDataSourceProvider),
  );
});
