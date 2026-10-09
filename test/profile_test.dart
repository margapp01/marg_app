import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marg_app/app/localization/app_localizations.dart';
import 'package:marg_app/app/theme/app_theme.dart';
import 'package:marg_app/features/profile/domain/entities/app_preferences.dart';
import 'package:marg_app/features/profile/domain/entities/cms_content.dart';
import 'package:marg_app/features/profile/domain/entities/profile.dart';
import 'package:marg_app/features/profile/domain/entities/user_device.dart';
import 'package:marg_app/features/profile/presentation/widgets/profile_widgets.dart';

void main() {
  group('Profile parsing', () {
    test('parses the /my/profile contract incl. member-since', () {
      final p = Profile.fromJson(const {
        'id': 'u1',
        'email': 'a@b.com',
        'phone': '+91 98765 43210',
        'name': 'Rahul Sharma',
        'gender': 'MALE',
        'city': 'Ujjain',
        'preferredLanguage': 'HI',
        'interests': ['TEMPLE_VISITS', 'ACHIEVEMENTS'],
        'isPhoneVerified': true,
        'createdAt': '2024-05-12T00:00:00.000Z',
      });
      expect(p.name, 'Rahul Sharma');
      expect(p.preferredLanguage, 'HI');
      expect(ProfileGender.fromWire(p.gender), ProfileGender.male);
      expect(p.interests.map(UserInterest.fromWire).whereType<UserInterest>(), contains(UserInterest.templeVisits));
      expect(p.isPhoneVerified, isTrue);
      expect(p.memberSince, isNotNull);
    });

    test('UserInterest + Gender fromWire round-trip', () {
      expect(UserInterest.fromWire('PUJA_PANDIT'), UserInterest.pujaPandit);
      expect(UserInterest.fromWire('NOPE'), isNull);
      expect(ProfileGender.fromWire('PREFER_NOT_TO_SAY'), ProfileGender.preferNotToSay);
    });
  });

  test('UserDevice parses platform + lastSeen', () {
    final d = UserDevice.fromJson(const {'id': 'd1', 'platform': 'IOS', 'deviceModel': 'iPhone 14 Pro', 'isActive': true, 'lastSeenAt': '2024-05-02T10:30:00.000Z'});
    expect(d.platform, 'IOS');
    expect(d.deviceModel, 'iPhone 14 Pro');
    expect(d.lastSeenAt, isNotNull);
  });

  test('StaticPage strips HTML to plain text', () {
    const page = StaticPage(title: 'Privacy', contentHtml: '<h1>Hello</h1><p>Line one.</p><p>Line two &amp; more.</p>');
    final text = page.plainText;
    expect(text, contains('Hello'));
    expect(text, contains('Line one.'));
    expect(text, contains('&'));
    expect(text.contains('<'), isFalse);
  });

  test('AppPreferences copyWith preserves other fields', () {
    const p = AppPreferences();
    expect(p.units, DistanceUnit.kilometers);
    expect(p.highQualityImages, isTrue);
    final next = p.copyWith(reduceAnimations: true, units: DistanceUnit.miles);
    expect(next.reduceAnimations, isTrue);
    expect(next.units, DistanceUnit.miles);
    expect(next.highQualityImages, isTrue); // unchanged
  });

  testWidgets('ProfileStatTile renders value + label', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: ProfileStatTile(icon: Icons.star, value: '156', label: 'Visits')),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('156'), findsOneWidget);
    expect(find.text('Visits'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
