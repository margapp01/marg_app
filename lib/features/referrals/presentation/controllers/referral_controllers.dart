import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repository/referral_repository.dart';
import '../../domain/entities/referral_models.dart';

/// The referral dashboard summary (`GET /my/referral`).
final referralSummaryProvider = FutureProvider.autoDispose<ReferralSummary>(
  (ref) => ref.watch(referralRepositoryProvider).summary(),
);

/// First page of reward history (dashboard "recent activity" + rewards screen).
final referralRewardsProvider = FutureProvider.autoDispose<Paged<ReferralReward>>(
  (ref) => ref.watch(referralRepositoryProvider).rewards(page: 1, limit: 30),
);

/// Referral invite history / timeline (`GET /my/referrals`).
final referralInvitesProvider = FutureProvider.autoDispose<Paged<ReferralInvite>>(
  (ref) => ref.watch(referralRepositoryProvider).invites(page: 1, limit: 50),
);

/// National referral leaderboard (`GET /referrals/leaderboard`).
final referralLeaderboardProvider = FutureProvider.autoDispose<List<LeaderRow>>(
  (ref) => ref.watch(referralRepositoryProvider).leaderboard(),
);

/// Client-derived referral analytics.
final referralAnalyticsProvider = FutureProvider.autoDispose<ReferralAnalytics>(
  (ref) => ref.watch(referralRepositoryProvider).analytics(),
);

/// A parsed FAQ entry.
typedef ReferralFaq = ({String question, String answer, String category});

/// Referral FAQs (from the CMS), filtered to referral-relevant categories.
final referralFaqsProvider = FutureProvider.autoDispose<List<ReferralFaq>>((ref) async {
  final raw = await ref.watch(referralRepositoryProvider).faqs();
  return raw
      .map((m) => (
            question: (m['question'] as String?) ?? '',
            answer: (m['answer'] as String?) ?? '',
            category: (m['category'] as String?) ?? '',
          ))
      .where((f) => f.question.isNotEmpty)
      .toList(growable: false);
});
