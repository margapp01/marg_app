import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/constants/app_constants.dart';

/// The Play Store install referrer — how this install reached the store
/// (e.g. `utm_source=margapp.in&utm_medium=invite&ref=CODE` from a friend's
/// invite page). Android only; null elsewhere or when unavailable.
class InstallReferrerService {
  const InstallReferrerService();

  Future<String?> read() async {
    if (kIsWeb || !Platform.isAndroid) return null;
    try {
      final referrer = await const MethodChannel(AppConstants.deviceChannel).invokeMethod<String>('installReferrer');
      return (referrer == null || referrer.isEmpty) ? null : referrer;
    } catch (_) {
      return null;
    }
  }
}

final installReferrerServiceProvider = Provider<InstallReferrerService>((ref) => const InstallReferrerService());
