import '../entities/auth_user.dart';
import '../entities/onboarding_draft.dart';

/// Persists the onboarding draft and returns the finalised, onboarded user.
abstract interface class OnboardingRepository {
  /// Runs the full onboarding submit in order:
  /// complete-registration (only when [requiresRegistration]) → profile →
  /// location → notification preferences → complete-onboarding → fetch user.
  Future<AuthUser> submit(
    OnboardingDraft draft, {
    required bool requiresRegistration,
  });
}
