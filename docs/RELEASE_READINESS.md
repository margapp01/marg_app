# MARG — Release Readiness (Phase 22.8)

Engineering polish is complete and the app builds, analyzes clean, and passes all
tests. The items below are **manual / credentialed tasks** that only the project
owner can complete — they were deliberately **not fabricated**.

## Firebase
- Firebase is initialized (`lib/app/bootstrap.dart`) with real `firebase_options.dart`, `google-services.json`, and `GoogleService-Info.plist`.
- **Release-build dependency conflict FIXED**: `firebase_core_platform_interface` had resolved to 7.1.0 (which removed `FirebasePlugin`/`pluginConstants`) while the plugins still referenced them, so `flutter build apk --release` failed to compile even though `analyze`/`test` passed (they don't compile dependency internals). Resolved with a firebase-scoped `flutter pub upgrade` → a consistent set (`firebase_core` 4.12.1, `firebase_core_platform_interface` 8.0.0, matching plugin bumps). Re-run `flutter pub get` after cloning; `pubspec.lock` is not committed.
- **Crashlytics** — now wired: `FlutterError.onError` + `platformDispatcher.onError` report to Crashlytics; collection is disabled in debug. ✅ code-complete.
- **Analytics** — `FirebaseAnalyticsObserver` is attached to the router for automatic `screen_view` tracking. ✅ code-complete. Add custom `logEvent` calls later if product wants funnel events.
- **Performance Monitoring** — dependency not added. To enable: add `firebase_performance`, it auto-collects HTTP/screen traces. *(Manual — optional.)*
- Manual: verify the Crashlytics dSYM upload build phase (iOS) and that the Android Crashlytics Gradle plugin is applied for symbol upload on release builds.

## Signing (required before store upload)
- **App id** — `com.techluminix.marg` on both Android (`applicationId`/`namespace`) and iOS (`PRODUCT_BUNDLE_IDENTIFIER`). Firebase apps for this id must exist in `marg-app-in` (see `../docs/DEPLOYMENT_FLOW.md` Phase 4).
- **Android** — `build.gradle.kts` signs release with the upload keystore from `android/key.properties` (template: `android/key.properties.example`); without that file it falls back to debug signing. *(Manual — create the keystore.)*
- **iOS** — signing is managed in Xcode; set the team and add the Push Notifications capability. *(Manual — needs Apple Developer account.)*

## Versioning
- `pubspec.yaml` is `version: 1.0.0+1`. Bump the build number (`+N`) on every store upload.

## Deep Links (routing is ready; OS wiring is manual)
- The GoRouter exposes a **stable path for every screen** (temple, route, card, achievement, passport, referral, knowledge article, festival), so path-based deep links resolve already.
- **Not yet wired at the OS level** (no fabricated domain):
  - **Android App Links** — add an `<intent-filter>` with `VIEW`/`BROWSABLE` + `android:autoVerify="true"` for your `https://<domain>` host in `AndroidManifest.xml`, and host `/.well-known/assetlinks.json`.
  - **iOS Universal Links** — add the `Associated Domains` entitlement (`applinks:<domain>`) and host `/.well-known/apple-app-site-association`.
  - Then map incoming paths to routes (GoRouter already matches them). *(Manual — needs the production domain + hosted verification files.)*

## Permissions & Privacy
- iOS: `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription`, and **`NSLocationWhenInUseUsageDescription`** (added this phase) are present.
- Android: `RECORD_AUDIO` was removed (no audio/video capture) to avoid a Play Data-safety flag. Remaining permissions (INTERNET, NETWORK_STATE, CAMERA, media/storage, POST_NOTIFICATIONS, WAKE_LOCK, RECEIVE_BOOT_COMPLETED) are all used by image_picker / FCM / connectivity.
- Cleartext (`http://`) is allowed only in debug builds (`src/debug/AndroidManifest.xml`); release is HTTPS-only. Release builds default to `https://api.margapp.in/api/v1` (`AppConfig`).
- Complete the **Play Data Safety** form and **Apple Privacy Nutrition Labels** (collects: location, email/name via Google, device token). *(Manual.)*

## Icons & Splash
- `flutter_launcher_icons` is a dev dependency; icons are generated (Android mipmaps + iOS AppIcon set present). Re-run `dart run flutter_launcher_icons` if the art changes. ✅
- **`flutter_native_splash` removed from `dev_dependencies`** — v2.4.7 declares an Android `pluginClass` (`FlutterNativeSplashPlugin`) whose class isn't compiled into the app, so it was injected into `GeneratedPluginRegistrant.java` and **broke the release build** (`package net.jonhanson.flutter_native_splash does not exist`). The generated splash assets are already committed and still work. To regenerate splash: temporarily re-add it to `dev_dependencies`, run `dart run flutter_native_splash:create`, then remove it again (config block retained in `pubspec.yaml`).

## Store Listings (content deliverables)
- Play Store + App Store: title, short/full description, screenshots (phone + tablet), feature graphic, category, content rating questionnaire, privacy-policy URL (the app already serves Privacy/Terms via CMS static pages). *(Manual — content.)*

## Localization (Phase 22.9)
- **Onboarding is now fully bilingual** — all ~70 user-facing strings across the 5 setup steps + the setup shell go through `AppLocalizations` (87 new `su*` keys in EN + HI). Enum display labels use `localizedLabel()` / `localizedTitle()` extensions in `setup_models.dart`; the `wire` values are untouched (backend contract preserved).
- ARB parity verified: **960 keys in both** `app_en.arb` and `app_hi.arb`, zero missing on either side.
- **Known gap:** month abbreviations in the date-of-birth field and article dates are still English (`Jan`, `Feb`, …) app-wide. Consistent across the app; localize with `intl`'s `DateFormat` in a follow-up if Hindi month names are wanted.

## Deep Links (Phase 22.9)
- Added a router **`errorBuilder`** — an unknown/stale/malformed link now renders the shared `ErrorView` ("Page not found" + "Go to Home") instead of GoRouter's raw red debug page.

## Reduce Animations
- Honored app-wide: `MediaQuery.disableAnimations` is set from the user preference, and the shared entrance primitive (`AppEntrance` → FadeIn/ScaleIn/SlideIn/`.animate*`/`StaggeredList`), `AnimatedCount`/`AnimatedNumber`, and `ConfettiOverlay` all respect it. ✅
