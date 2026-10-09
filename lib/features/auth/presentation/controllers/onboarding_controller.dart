import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repository/onboarding_repository_impl.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/entities/onboarding_draft.dart';
import 'auth_controller.dart';

/// Drives the final onboarding submit. Holds an [AsyncValue] the setup page
/// watches for the busy/error states; on success it promotes the finalised
/// user into [AuthController] so the router guard lets the app through.
class OnboardingController extends Notifier<AsyncValue<AuthUser?>> {
  @override
  AsyncValue<AuthUser?> build() => const AsyncData(null);

  Future<AuthUser?> submit(
    OnboardingDraft draft, {
    required bool requiresRegistration,
  }) async {
    state = const AsyncLoading();
    try {
      final user = await ref.read(onboardingRepositoryProvider).submit(
            draft,
            requiresRegistration: requiresRegistration,
          );
      ref.read(authControllerProvider.notifier).setAuthenticated(user);
      state = AsyncData(user);
      return user;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}

final onboardingControllerProvider =
    NotifierProvider<OnboardingController, AsyncValue<AuthUser?>>(
  OnboardingController.new,
);
