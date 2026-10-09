import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/referral_models.dart';
import '../datasource/referral_remote_datasource.dart';

/// Orchestrates the referral datasource + derives client-side analytics from the
/// real summary + invite history (no user-facing analytics endpoint exists).
class ReferralRepository {
  ReferralRepository(this._remote);
  final ReferralRemoteDataSource _remote;

  Future<ReferralSummary> summary() => _remote.summary();
  Future<Paged<ReferralReward>> rewards({int page = 1, int limit = 20}) => _remote.rewards(page: page, limit: limit);
  Future<Paged<ReferralInvite>> invites({int page = 1, int limit = 20}) => _remote.invites(page: page, limit: limit);
  Future<List<LeaderRow>> leaderboard() => _remote.leaderboard();
  Future<List<Map<String, dynamic>>> faqs() => _remote.faqs();

  /// Derives analytics from the summary (invites/joined/conversion) + a page of
  /// invite history (monthly activity + top source).
  Future<ReferralAnalytics> analytics() async {
    final summary = await _remote.summary();
    final invites = (await _remote.invites(page: 1, limit: 100)).items;

    // Trailing six months of invites, oldest → newest.
    const labels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final now = DateTime.now();
    final monthly = <(String, int)>[];
    for (var k = 5; k >= 0; k--) {
      final d = DateTime(now.year, now.month - k);
      final count = invites.where((i) => i.createdAt != null && i.createdAt!.year == d.year && i.createdAt!.month == d.month).length;
      monthly.add((labels[d.month - 1], count));
    }

    // Top sharing source (most frequent non-null `source`).
    final counts = <String, int>{};
    for (final i in invites) {
      final s = i.source;
      if (s != null && s.isNotEmpty) counts[s] = (counts[s] ?? 0) + 1;
    }
    String? topSource;
    int? topPct;
    if (counts.isNotEmpty) {
      final top = counts.entries.reduce((a, b) => a.value >= b.value ? a : b);
      final withSource = counts.values.fold<int>(0, (n, v) => n + v);
      topSource = top.key;
      topPct = withSource == 0 ? null : (top.value * 100 / withSource).round();
    }

    final conversion = summary.totalInvites == 0 ? 0.0 : summary.successfulInvites * 100 / summary.totalInvites;
    return ReferralAnalytics(
      invitesSent: summary.totalInvites,
      joined: summary.successfulInvites,
      conversionPercent: conversion,
      monthly: monthly,
      topSource: topSource,
      topSourcePercent: topPct,
    );
  }
}

final referralRepositoryProvider = Provider<ReferralRepository>(
  (ref) => ReferralRepository(ref.watch(referralRemoteDataSourceProvider)),
);
