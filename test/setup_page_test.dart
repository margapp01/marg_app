import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:marg_app/app/localization/app_localizations.dart';
import 'package:marg_app/app/router/route_names.dart';
import 'package:marg_app/app/theme/app_theme.dart';
import 'package:marg_app/features/auth/data/repository/onboarding_repository_impl.dart';
import 'package:marg_app/features/auth/domain/entities/auth_user.dart';
import 'package:marg_app/features/auth/domain/entities/onboarding_draft.dart';
import 'package:marg_app/features/auth/domain/repository/onboarding_repository.dart';
import 'package:marg_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:marg_app/features/auth/presentation/pages/setup_page.dart';
import 'package:marg_app/features/auth/presentation/states/auth_state.dart';

/// Captures the submitted draft and returns an onboarded user, offline.
class _FakeOnboardingRepository implements OnboardingRepository {
  OnboardingDraft? submitted;

  @override
  Future<AuthUser> submit(OnboardingDraft draft, {required bool requiresRegistration}) async {
    submitted = draft;
    return AuthUser(
      id: 'u1',
      name: 'Test Devotee',
      email: 'test@gmail.com',
      onboardingCompletedAt: DateTime(2026, 1, 1),
    );
  }
}

/// A brand-new Google account (needs a mobile) whose number the backend
/// rejects as already registered.
class _MobileTakenAuthController extends AuthController {
  int attempts = 0;

  @override
  AuthState build() => const AuthState(status: AuthStatus.needsMobile);

  @override
  Future<void> completeRegistration({required String mobile, String? name, String? profilePhoto}) async {
    attempts++;
    final request = RequestOptions(path: '/auth/complete-registration');
    throw DioException(
      requestOptions: request,
      response: Response(
        requestOptions: request,
        statusCode: 409,
        data: {'success': false, 'message': 'Mobile number already in use', 'errors': <Object>[]},
      ),
    );
  }
}

GoRouter _setupRouter() => GoRouter(
      initialLocation: '/setup',
      routes: [
        GoRoute(path: '/setup', builder: (_, _) => const SetupPage()),
        GoRoute(path: '/home', name: RouteNames.home, builder: (_, _) => const Text('HOME')),
        GoRoute(path: '/auth', name: RouteNames.auth, builder: (_, _) => const Text('AUTH')),
      ],
    );

void main() {
  testWidgets('setup flow walks all five steps, saves, celebrates, then goes home', (tester) async {
    final repo = _FakeOnboardingRepository();
    final router = _setupRouter();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [onboardingRepositoryProvider.overrideWithValue(repo)],
        child: MaterialApp.router(
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pump();

    Future<void> next() async {
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
    }

    expect(find.text('Welcome to Marg! 🙏'), findsOneWidget);
    expect(find.text('Step 1 of 5', findRichText: true), findsOneWidget);
    await next();

    expect(find.text('Tell Us About You'), findsOneWidget);
    // Date of birth is required (18+): Continue without it stays on the step,
    // with the reason inline and in a toast.
    await next();
    expect(find.text('Select your date of birth to continue'), findsNWidgets(2));
    expect(find.text('Tell Us About You'), findsOneWidget);
    // The picker opens on an adult default date; confirming it clears that error.
    await tester.tap(find.text('Select your date of birth'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    // Gender is required too.
    await next();
    expect(find.text('Select your gender to continue'), findsNWidgets(2));
    expect(find.text('Tell Us About You'), findsOneWidget);
    await tester.tap(find.text('Female'));
    await tester.pump();
    expect(find.text('Select your gender to continue'), findsOneWidget, reason: 'inline error clears; toast remains');
    await next();

    expect(find.text('What Brings You Here?'), findsOneWidget);
    await next();

    expect(find.text('Your Spiritual Preferences'), findsOneWidget);
    await tester.tap(find.text('Shiva'));
    await tester.pump();
    await next();

    // Review shows the answers, then "Complete Setup" submits once.
    expect(find.text('Almost Done! 🎉'), findsOneWidget);
    expect(find.text('Shiva'), findsWidgets);
    await tester.tap(find.text('Complete Setup'));
    await tester.pumpAndSettle();

    expect(repo.submitted?.favoriteDeities, ['SHIVA']);
    expect(repo.submitted?.profilePatch()['favoriteDeities'], ['SHIVA']);

    // Saved → "You're all set!", and "Start My Journey" enters the app.
    expect(find.text("You're all set! 🎉"), findsOneWidget);
    await tester.tap(find.text('Start My Journey'));
    await tester.pumpAndSettle();
    expect(find.text('HOME'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('an already-registered mobile is rejected on the first step', (tester) async {
    final auth = _MobileTakenAuthController();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authControllerProvider.overrideWith(() => auth)],
        child: MaterialApp.router(
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: _setupRouter(),
        ),
      ),
    );
    await tester.pump();

    final mobile = find.byType(TextField).last;
    await tester.ensureVisible(mobile);
    await tester.pumpAndSettle();
    await tester.enterText(mobile, '9876543210');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(auth.attempts, 1);
    const taken = 'This mobile number is already registered. Please use a different number.';
    expect(find.text(taken), findsNWidgets(2), reason: 'inline under the field + toast');
    expect(find.text('Step 1 of 5', findRichText: true), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
  });
}
