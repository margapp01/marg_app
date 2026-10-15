import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marg_app/core/services/share_service.dart';

void main() {
  group('ShareLinks', () {
    test('tags a website page with the referral code and campaign', () {
      final url = Uri.parse(ShareLinks.web(SharePaths.temple('kashi-vishwanath'), kind: ShareKind.temple, ref: 'MARG1088'));
      expect(url.origin, 'https://margapp.in');
      expect(url.path, '/temples/kashi-vishwanath');
      expect(url.queryParameters, {'ref': 'MARG1088', 'utm_source': 'app_share', 'utm_medium': 'temple'});
    });

    test('omits an empty referral code', () {
      final url = Uri.parse(ShareLinks.web('/passport/tok', kind: ShareKind.passport, ref: ''));
      expect(url.queryParameters.containsKey('ref'), isFalse);
      expect(url.path, '/passport/tok');
    });

    test('Play Store link carries the campaign as the install referrer', () {
      final url = Uri.parse(ShareLinks.playStore(kind: ShareKind.achievement));
      expect(url.queryParameters['id'], 'com.techluminix.marg');
      expect(url.queryParameters['referrer'], 'utm_source=app_share&utm_medium=achievement');
    });
  });

  group('ShareService.linkFor', () {
    ProviderContainer container(String? code) =>
        ProviderContainer(overrides: [shareReferralCodeProvider.overrideWith((ref) async => code)]);

    test('a page share lands on that page, tagged with the sharer', () async {
      final c = container('ABC123');
      addTearDown(c.dispose);
      final link = await c.read(shareServiceProvider).linkFor(
            const ShareMessage(kind: ShareKind.card, text: 't', path: '/cards/c1'),
          );
      expect(link, 'https://margapp.in/cards/c1?ref=ABC123&utm_source=app_share&utm_medium=card');
    });

    test('a share without a page lands on the sharer\'s invite', () async {
      final c = container('ABC123');
      addTearDown(c.dispose);
      final link = await c.read(shareServiceProvider).linkFor(const ShareMessage(kind: ShareKind.achievement, text: 't'));
      expect(link, 'https://margapp.in/invite/ABC123?utm_source=app_share&utm_medium=achievement');
    });

    test('falls back to the Play Store when there is no code', () async {
      final c = container(null);
      addTearDown(c.dispose);
      final link = await c.read(shareServiceProvider).linkFor(const ShareMessage(kind: ShareKind.quote, text: 't'));
      expect(link, startsWith('https://play.google.com/store/apps/details?id=com.techluminix.marg'));
    });
  });
}
