import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/dio_client.dart';
import '../features/auth/data/datasource/auth_remote_datasource.dart';
import '../features/auth/data/datasource/firebase_google_auth_service.dart';
import '../features/auth/domain/repository/google_auth_service.dart';
import '../firebase_options.dart';
import 'app.dart';

/// Pre-runApp initialization, in dependency order: Firebase must be ready
/// before the first frame so session restore and Google sign-in work.
///
/// The app layer composes the feature implementations that `core` deliberately
/// doesn't depend on: the Firebase Google-auth service and the token refresher.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Crashlytics: route Flutter framework + uncaught async errors to Crashlytics.
  // Collection is disabled in debug so local development never sends reports.
  final crashlytics = FirebaseCrashlytics.instance;
  await crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);
  FlutterError.onError = crashlytics.recordFlutterFatalError;
  WidgetsBinding.instance.platformDispatcher.onError = (error, stack) {
    crashlytics.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(
    ProviderScope(
      overrides: [
        googleAuthServiceProvider.overrideWithValue(FirebaseGoogleAuthService()),
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
