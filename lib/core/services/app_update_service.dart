import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/constants/app_constants.dart';
import '../network/dio_client.dart';
import '../storage/key_value_store.dart';
import '../storage/shared_prefs_store.dart';

/// How far behind the latest release this install is.
///  - [major]: a major version behind, or below the minimum supported — the
///    app can't be used until it updates.
///  - [minor]: asked to update; "Later" waits [AppUpdateService.remindAfter].
///  - [patch]: a gentle hint, shown once per version.
enum UpdateLevel { none, patch, minor, major }

/// A `MAJOR.MINOR.PATCH` version (any `+build` suffix is ignored).
@immutable
class AppVersion implements Comparable<AppVersion> {
  const AppVersion(this.major, this.minor, this.patch);

  final int major;
  final int minor;
  final int patch;

  static final _pattern = RegExp(r'^(\d+)\.(\d+)\.(\d+)');

  static AppVersion? tryParse(String? value) {
    final m = value == null ? null : _pattern.firstMatch(value.trim());
    if (m == null) return null;
    return AppVersion(int.parse(m[1]!), int.parse(m[2]!), int.parse(m[3]!));
  }

  @override
  int compareTo(AppVersion other) {
    if (major != other.major) return major - other.major;
    if (minor != other.minor) return minor - other.minor;
    return patch - other.patch;
  }

  bool operator <(AppVersion other) => compareTo(other) < 0;

  @override
  bool operator ==(Object other) => other is AppVersion && compareTo(other) == 0;

  @override
  int get hashCode => Object.hash(major, minor, patch);

  @override
  String toString() => '$major.$minor.$patch';
}

/// The Android release policy set in admin (`GET /app/release`).
@immutable
class AppRelease {
  const AppRelease({this.latest, this.minimum, this.notes});

  final AppVersion? latest;
  final AppVersion? minimum;
  final String? notes;

  factory AppRelease.fromJson(Map<String, dynamic> json) {
    final android = (json['android'] as Map?)?.cast<String, dynamic>() ?? const {};
    final notes = android['releaseNotes'] as String?;
    return AppRelease(
      latest: AppVersion.tryParse(android['latestVersion'] as String?),
      minimum: AppVersion.tryParse(android['minVersion'] as String?),
      notes: notes == null || notes.trim().isEmpty ? null : notes.trim(),
    );
  }

  /// The prompt [current] calls for.
  UpdateLevel levelFor(AppVersion current) {
    final min = minimum;
    if (min != null && current < min) return UpdateLevel.major;
    final next = latest;
    if (next == null || !(current < next)) return UpdateLevel.none;
    if (next.major > current.major) return UpdateLevel.major;
    if (next.minor > current.minor) return UpdateLevel.minor;
    return UpdateLevel.patch;
  }
}

/// An update this install should be told about.
@immutable
class AppUpdateCheck {
  const AppUpdateCheck({required this.level, required this.version, this.notes});

  final UpdateLevel level;

  /// The latest version, as shown to the pilgrim.
  final String version;
  final String? notes;
}

/// Decides when to prompt for an app update and runs the update through
/// Google Play's in-app update flow (immediate for required/minor updates,
/// flexible for patches), falling back to the Play Store listing when Play
/// can't offer one (e.g. a sideloaded build, or the rollout hasn't reached
/// this device yet).
class AppUpdateService {
  AppUpdateService({required Dio dio, required KeyValueStore store})
      : _dio = dio,
        _store = store;

  final Dio _dio;
  final KeyValueStore _store;

  /// How long "Later" on a minor update holds the prompt back.
  static const Duration remindAfter = Duration(days: 3);
  static const _snoozeKey = 'appUpdate.snoozed';

  /// The update to prompt for now, or null. Android only (the release policy
  /// is per platform and only Android ships today).
  Future<AppUpdateCheck?> check() async {
    if (kIsWeb || !Platform.isAndroid) return null;
    try {
      final res = await _dio.get<dynamic>('/app/release');
      final release = AppRelease.fromJson(((res.data as Map)['data'] as Map).cast<String, dynamic>());
      final current = AppVersion.tryParse((await PackageInfo.fromPlatform()).version);
      if (current == null) return null;
      final level = release.levelFor(current);
      if (level == UpdateLevel.none) return null;
      final version = (release.latest ?? release.minimum).toString();
      if (!shouldPrompt(level, version: version, snoozed: await _store.getString(_snoozeKey), now: DateTime.now())) {
        return null;
      }
      return AppUpdateCheck(level: level, version: version, notes: release.notes);
    } catch (_) {
      return null; // never block the app on a failed check
    }
  }

  /// Whether a [level] prompt for [version] should show, given the last
  /// "Later" ([snoozed] = `version|isoTime`). Required updates always show.
  static bool shouldPrompt(UpdateLevel level, {required String version, required String? snoozed, required DateTime now}) {
    if (level == UpdateLevel.major) return true;
    final parts = snoozed?.split('|');
    if (parts == null || parts.length != 2 || parts[0] != version) return true;
    if (level == UpdateLevel.patch) return false; // once per version
    final at = DateTime.tryParse(parts[1]);
    return at == null || now.difference(at) >= remindAfter;
  }

  /// Remembers "Later" for [check] (never called for required updates).
  Future<void> snooze(AppUpdateCheck check) =>
      _store.setString(_snoozeKey, '${check.version}|${DateTime.now().toIso8601String()}');

  /// Starts the update. [immediate] uses Play's full-screen flow; otherwise
  /// Play downloads in the background and restarts the app when ready.
  /// Returns false when the pilgrim cancelled Play's update screen.
  Future<bool> update({required bool immediate}) async {
    try {
      final info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        if (immediate && info.immediateUpdateAllowed) {
          return await InAppUpdate.performImmediateUpdate() == AppUpdateResult.success;
        }
        if (!immediate && info.flexibleUpdateAllowed) {
          if (await InAppUpdate.startFlexibleUpdate() != AppUpdateResult.success) return false;
          await InAppUpdate.completeFlexibleUpdate();
          return true;
        }
      }
    } catch (_) {/* Play unavailable — fall back to the store listing */}
    await launchUrl(Uri.parse(AppConstants.playStoreUrl), mode: LaunchMode.externalApplication);
    return true;
  }
}

final appUpdateServiceProvider = Provider<AppUpdateService>(
  (ref) => AppUpdateService(dio: ref.watch(dioProvider), store: ref.watch(keyValueStoreProvider)),
);
