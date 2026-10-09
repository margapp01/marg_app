import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marg_app/app/localization/app_localizations.dart';
import 'package:marg_app/app/theme/app_theme.dart';
import 'package:marg_app/features/referrals/domain/entities/referral_models.dart';
import 'package:marg_app/features/referrals/presentation/widgets/referral_widgets.dart';

void main() {
  group('ReferralSummary', () {
    test('parses summary, composes invite link, and computes milestone progress', () {
      final s = ReferralSummary.fromJson(const {
        'code': 'MARG1088',
        'totalInvites': 128,
        'successfulInvites': 36,
        'pointsEarned': 2480,
        'nextMilestone': 50,
        'referralsToNextMilestone': 14,
      });
      expect(s.code, 'MARG1088');
      expect(s.inviteLink, '$kReferralLinkBase/MARG1088');
      expect(s.milestoneProgress, closeTo(36 / 50, 0.001));
    });

    test('full milestone progress when no next milestone', () {
      final s = ReferralSummary.fromJson(const {'code': 'X', 'totalInvites': 100, 'successfulInvites': 100, 'pointsEarned': 9000});
      expect(s.milestoneProgress, 1.0);
    });
  });

  group('ReferralReward + status', () {
    test('parses reward with friend name and derives points', () {
      final r = ReferralReward.fromJson(const {
        'id': 'r1',
        'rewardType': 'POINTS',
        'rewardValue': '150',
        'awardedAt': '2026-05-07T00:00:00.000Z',
        'referredUser': {'id': 'u2', 'name': 'Neha Singh', 'profilePhoto': null},
      });
      expect(r.type, ReferralRewardType.points);
      expect(r.friendName, 'Neha Singh');
      expect(r.points, 150);
    });

    test('non-points reward yields null points', () {
      final r = ReferralReward.fromJson(const {'id': 'r2', 'rewardType': 'CARD', 'rewardValue': 'referral-rare'});
      expect(r.type, ReferralRewardType.card);
      expect(r.points, isNull);
    });

    test('ReferralStatus maps wire values', () {
      expect(ReferralStatus.fromWire('COMPLETED'), ReferralStatus.completed);
      expect(ReferralStatus.fromWire('REWARDED'), ReferralStatus.rewarded);
      expect(ReferralStatus.fromWire('WAT'), ReferralStatus.unknown);
    });
  });

  test('Paged.fromEnvelope reads pagination + maps rows', () {
    final page = Paged.fromEnvelope(const {
      'data': [
        {'id': 'a', 'status': 'PENDING', 'source': 'whatsapp', 'createdAt': '2026-05-02T00:00:00.000Z'},
      ],
      'pagination': {'page': 1, 'totalPages': 3, 'total': 45},
    }, ReferralInvite.fromJson);
    expect(page.items, hasLength(1));
    expect(page.items.first.status, ReferralStatus.pending);
    expect(page.hasMore, isTrue);
  });

  testWidgets('LeaderTile shows "You" and points for the current user', (tester) async {
    const row = LeaderRow(position: 1, userId: 'me', points: 12480, displayName: 'Rahul');
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: LeaderTile(row: row, isCurrentUser: true)),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('You'), findsOneWidget);
    expect(find.textContaining('12480'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
