import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../app/constants/app_constants.dart';

/// Device identity gathered for check-in anti-fraud. These are best-effort
/// signals the backend records against a visit; the backend — never the client
/// — decides the verification verdict.
///
/// Note: root/jailbreak detection is not available without a native plugin, so
/// [isRooted] is a conservative `false`. WiFi BSSID / cell-tower id are not
/// collected (they need extra permissions the app does not request), so the
/// check-in omits `networkInfo` rather than sending fabricated values.
@immutable
class DeviceContext {
  const DeviceContext({
    required this.platform,
    this.deviceId,
    this.deviceModel,
    this.appVersion,
    this.isRooted = false,
  });

  /// Backend `Platform` enum: ANDROID / IOS / WEB.
  final String platform;

  /// Stable identifier of this phone (Android `ANDROID_ID`, iOS
  /// `identifierForVendor`). The backend uses it to stop one phone checking
  /// several accounts in at the same temple on the same day.
  final String? deviceId;
  final String? deviceModel;
  final String? appVersion;
  final bool isRooted;

  static const DeviceContext unknown = DeviceContext(platform: 'WEB');
}

/// Collects [DeviceContext] once and caches it for the session.
class DeviceContextService {
  DeviceContextService();

  DeviceContext? _cached;

  Future<DeviceContext> load() async {
    final cached = _cached;
    if (cached != null) return cached;

    final ctx = await _read();
    _cached = ctx;
    return ctx;
  }

  Future<DeviceContext> _read() async {
    if (kIsWeb) return DeviceContext.unknown;

    final info = DeviceInfoPlugin();
    String? appVersion;
    try {
      appVersion = (await PackageInfo.fromPlatform()).version;
    } catch (_) {
      appVersion = null;
    }

    try {
      if (Platform.isAndroid) {
        final a = await info.androidInfo;
        return DeviceContext(
          platform: 'ANDROID',
          deviceId: await _androidId(),
          deviceModel: '${a.manufacturer} ${a.model}'.trim(),
          appVersion: appVersion,
        );
      }
      if (Platform.isIOS) {
        final i = await info.iosInfo;
        return DeviceContext(
          platform: 'IOS',
          deviceId: i.identifierForVendor,
          deviceModel: i.utsname.machine,
          appVersion: appVersion,
        );
      }
    } catch (_) {
      // Fall through to a minimal context — never block a check-in on this.
    }
    return DeviceContext(
      platform: Platform.isIOS ? 'IOS' : 'ANDROID',
      appVersion: appVersion,
    );
  }
}

/// `ANDROID_ID`, or null when unavailable (never `Build.ID`, which is shared
/// by every phone on the same firmware).
Future<String?> _androidId() async {
  try {
    final id = await const MethodChannel(AppConstants.deviceChannel).invokeMethod<String>('androidId');
    return (id == null || id.isEmpty) ? null : id;
  } catch (_) {
    return null;
  }
}

final deviceContextServiceProvider =
    Provider<DeviceContextService>((ref) => DeviceContextService());
