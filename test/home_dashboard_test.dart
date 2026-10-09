import 'package:flutter_test/flutter_test.dart';
import 'package:marg_app/features/home/domain/entities/home_dashboard.dart';

void main() {
  group('HomeDashboard.fromJson', () {
    test('parses the frozen /home/dashboard contract', () {
      final d = HomeDashboard.fromJson(<String, dynamic>{
        'meta': {'schemaVersion': '1.0', 'generatedAt': '2026-07-21T09:41:00.000Z'},
        'profile': {'id': 'u1', 'name': 'Aarav', 'preferredLanguage': 'EN', 'city': 'Varanasi'},
        'greeting': {'salutation': 'Namaste', 'timeOfDay': 'MORNING'},
        'banners': [
          {'id': 'b1', 'title': 'Kashi', 'subtitle': 'Darshan', 'imageUrl': 'https://x/y.jpg', 'ctaLabel': 'Explore'},
        ],
        'dailyQuote': {'id': 'q1', 'text': 'Do your duty', 'textHi': 'कर्म करो', 'reference': 'Gita 2.47'},
        'passport': {
          'trustScore': 80,
          'statistics': {'totalVisitedTemples': 6, 'cardsCollected': 3, 'routesCompleted': 1},
          'completion': {
            'passportCompletion': 42.5,
            'breakdown': {'templesPercent': 50, 'cardsPercent': 17, 'routesPercent': 32},
          },
        },
        'leaderboardRank': {'rank': 2, 'tier': 'DEVOTEE', 'points': 2450, 'direction': 'UP', 'movement': 1},
        'referral': {'code': 'MARG123', 'successfulReferrals': 4},
        'unreadNotifications': 3,
        'recentActivity': [
          {'id': 'a1', 'type': 'VISIT', 'title': 'Visited Kashi', 'createdAt': '2026-07-20T08:30:00.000Z'},
        ],
        'upcomingFestivals': [
          {'id': 'f1', 'name': 'Rath Yatra', 'slug': 'rath-yatra', 'deity': 'Jagannath', 'startDate': '2026-07-07'},
        ],
        'nearbyTemples': [
          {'id': 't1', 'name': 'Kashi', 'slug': 'kashi', 'city': 'Varanasi', 'distanceMeters': 850, 'distanceKm': 0.9, 'formattedDistance': '850 m'},
        ],
        'explore': {
          'promotions': [{'id': 'p1', 'title': 'Virtual Darshan'}],
          'blogs': [{'id': 'bl1', 'title': 'Char Dham Guide', 'slug': 'char-dham'}],
        },
        'bookings': null,
        'pandits': null,
      });

      expect(d.profile?.name, 'Aarav');
      expect(d.greeting.timeOfDay, 'MORNING');
      expect(d.featuredBanner?.title, 'Kashi');
      expect(d.dailyQuote?.textHi, 'कर्म करो');
      expect(d.passport?.templesPercent, 50);
      expect(d.passport?.completion, 42.5);
      expect(d.leaderboard?.rank, 2);
      expect(d.referral?.code, 'MARG123');
      expect(d.unreadNotifications, 3);
      expect(d.recentActivity.single.type, 'VISIT');
      expect(d.upcomingFestivals.single.slug, 'rath-yatra');
      expect(d.nearbyTemples.single.formattedDistance, '850 m');
      expect(d.promotions.single.title, 'Virtual Darshan');
      expect(d.blogs.single.slug, 'char-dham');
    });

    test('degrades gracefully on an empty / partial payload', () {
      final d = HomeDashboard.fromJson(const <String, dynamic>{});
      expect(d.profile, isNull);
      expect(d.greeting.salutation, 'Namaste');
      expect(d.banners, isEmpty);
      expect(d.featuredBanner, isNull);
      expect(d.dailyQuote, isNull);
      expect(d.nearbyTemples, isEmpty);
      expect(d.unreadNotifications, 0);
    });
  });
}
