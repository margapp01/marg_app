import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/dio_client.dart';
import '../core/services/share_service.dart';
import '../features/auth/data/datasource/auth_remote_datasource.dart';
import '../features/auth/data/datasource/firebase_google_auth_service.dart';
import '../features/auth/domain/repository/google_auth_service.dart';
import '../features/auth/presentation/controllers/auth_controller.dart';
import '../features/referrals/data/repository/referral_repository.dart';
import '../firebase_options.dart';
import 'app.dart';

/// Pre-runApp initialization, in dependency order: Firebase must be ready
/// before the first frame so session restore and Google sign-in work.
///
/// The app layer composes the feature implementations that `core` deliberately
/// doesn't depend on: the Firebase Google-auth service, the token refresher and
/// the referral code every shared link carries.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Analytics and crash reports stay OFF until the consent screen ships: the
  // Privacy Policy promises nothing is collected without the user's consent.
  // The native manifests disable them before Flutter starts, too.
  await Future.wait([
    FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(false),
    FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false),
  ]);
  if (kDebugMode) FlutterError.onError = FlutterError.presentError;

  runApp(
    ProviderScope(
      overrides: [
        googleAuthServiceProvider.overrideWithValue(FirebaseGoogleAuthService()),
        shareReferralCodeProvider.overrideWith((ref) async {
          final userId = ref.watch(authControllerProvider.select((s) => s.user?.id));
          if (userId == null) return null;
          try {
            return (await ref.read(referralRepositoryProvider).summary()).code;
          } catch (_) {
            return null;
          }
        }),
        tokenRefresherProvider.overrideWith(
          (ref) => (refreshToken) async {
            try {
              return await ref.read(authRemoteDataSourceProvider).refresh(refreshToken);
            } catch (_) {
              return null;
            }
          },
        ),
      ],
      child: const MargApp(),
    ),
  );
}
