import 'package:flutter_test/flutter_test.dart';
import 'package:marg_app/core/services/app_update_service.dart';

void main() {
  AppRelease release({String? latest, String? min}) => AppRelease.fromJson({
        'android': {'latestVersion': latest, 'minVersion': min, 'releaseNotes': null},
      });
  final current = AppVersion.tryParse('1.4.2+17')!;

  group('update level', () {
    test('patch, minor and major steps behind', () {
      expect(release(latest: '1.4.3').levelFor(current), UpdateLevel.patch);
      expect(release(latest: '1.5.0').levelFor(current), UpdateLevel.minor);
      expect(release(latest: '2.0.0').levelFor(current), UpdateLevel.major);
    });

    test('nothing when up to date, ahead, or unset', () {
      expect(release(latest: '1.4.2').levelFor(current), UpdateLevel.none);
      expect(release(latest: '1.4.0').levelFor(current), UpdateLevel.none);
      expect(release().levelFor(current), UpdateLevel.none);
    });

    test('below the minimum is always required', () {
      expect(release(latest: '1.4.3', min: '1.4.3').levelFor(current), UpdateLevel.major);
      expect(release(min: '1.5.0').levelFor(current), UpdateLevel.major);
      expect(release(latest: '1.5.0', min: '1.0.0').levelFor(current), UpdateLevel.minor);
    });

    test('compares numerically, not as text', () {
      expect(release(latest: '1.10.0').levelFor(AppVersion.tryParse('1.9.9')!), UpdateLevel.minor);
    });
  });

  group('prompt frequency', () {
    final now = DateTime(2026, 10, 15, 12);
    String snoozed(String version, Duration ago) => '$version|${now.subtract(ago).toIso8601String()}';

    test('required updates always show', () {
      expect(AppUpdateService.shouldPrompt(UpdateLevel.major, version: '2.0.0', snoozed: snoozed('2.0.0', Duration.zero), now: now), isTrue);
    });

    test('a minor update waits three days after "Later"', () {
      expect(AppUpdateService.shouldPrompt(UpdateLevel.minor, version: '1.5.0', snoozed: snoozed('1.5.0', const Duration(days: 1)), now: now), isFalse);
      expect(AppUpdateService.shouldPrompt(UpdateLevel.minor, version: '1.5.0', snoozed: snoozed('1.5.0', const Duration(days: 3)), now: now), isTrue);
    });

    test('a patch hint shows once per version', () {
      expect(AppUpdateService.shouldPrompt(UpdateLevel.patch, version: '1.4.3', snoozed: snoozed('1.4.3', const Duration(days: 30)), now: now), isFalse);
      expect(AppUpdateService.shouldPrompt(UpdateLevel.patch, version: '1.4.4', snoozed: snoozed('1.4.3', Duration.zero), now: now), isTrue);
    });
  });
}
