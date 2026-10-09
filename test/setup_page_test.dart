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
import 'package:marg_app/features/auth/presentation/pages/setup_page.dart';

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

void main() {
  testWidgets('setup flow walks all five steps, saves, celebrates, then goes home', (tester) async {
    final repo = _FakeOnboardingRepository();
    final router = GoRouter(
      initialLocation: '/setup',
      routes: [
        GoRoute(path: '/setup', builder: (_, _) => const SetupPage()),
        GoRoute(path: '/home', name: RouteNames.home, builder: (_, _) => const Text('HOME')),
        GoRoute(path: '/auth', name: RouteNames.auth, builder: (_, _) => const Text('AUTH')),
      ],
    );
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
}
