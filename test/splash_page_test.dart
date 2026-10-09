import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marg_app/app/theme/app_theme.dart';
import 'package:marg_app/features/auth/data/repository/auth_repository_impl.dart';
import 'package:marg_app/features/auth/domain/entities/auth_user.dart';
import 'package:marg_app/features/auth/domain/entities/firebase_auth_result.dart';
import 'package:marg_app/features/auth/domain/repository/auth_repository.dart';
import 'package:marg_app/features/auth/presentation/pages/splash_page.dart';

/// No stored session — keeps the splash offline (no secure storage / network).
class _NoSessionAuthRepository implements AuthRepository {
  @override
  Future<AuthUser?> restoreSession() async => null;

  @override
  Future<AuthUser?> currentUser() async => null;

  @override
  Future<FirebaseAuthResult> signInWithGoogle() => throw UnimplementedError();

  @override
  Future<AuthUser> completeRegistration({
    required String mobile,
    String? name,
    String? profilePhoto,
  }) =>
      throw UnimplementedError();

  @override
  Future<void> signOut() async {}
}

void main() {
  testWidgets('splash renders wordmark, tagline and credit without errors', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(_NoSessionAuthRepository()),
        ],
        child: MaterialApp(theme: AppTheme.light, home: const SplashPage()),
      ),
    );
    // Pump past the entrance-animation delays (≤650ms) but before the 2.4s
    // min-brand timer, so no navigation runs and no delay future is pending.
    await tester.pump(const Duration(milliseconds: 900));

    expect(find.text('YOUR SACRED PATH.'), findsOneWidget);
    expect(find.text('TechLuminix'), findsOneWidget);
    expect(find.byType(Image), findsWidgets); // backdrop + wordmark + lotus
    expect(tester.takeException(), isNull);

    // Dispose the page so its pending timer is cancelled cleanly.
    await tester.pumpWidget(const SizedBox());
  });
}
