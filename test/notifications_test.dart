import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marg_app/app/localization/app_localizations.dart';
import 'package:marg_app/app/theme/app_theme.dart';
import 'package:marg_app/features/notifications/domain/entities/app_notification.dart';
import 'package:marg_app/features/notifications/domain/entities/hub_content.dart';
import 'package:marg_app/features/notifications/presentation/widgets/notification_link.dart';
import 'package:marg_app/features/notifications/presentation/widgets/notification_widgets.dart';

AppNotification _n({
  required String type,
  String? actionUrl,
  Map<String, dynamic>? metadata,
  bool isRead = false,
  DateTime? at,
}) =>
    AppNotification.fromJson({
      'id': 'n1',
      'type': type,
      'title': 'Title',
      'message': 'Message',
      'isRead': isRead,
      'createdAt': (at ?? DateTime.now()).toIso8601String(),
      'actionUrl': ?actionUrl,
      'metadata': ?metadata,
    });

void main() {
  group('AppNotification parsing', () {
    test('maps wire type to kind and reads metadata screen/entityId', () {
      final n = _n(type: 'VISIT', actionUrl: '/temples/kedarnath', metadata: {'screen': 'temple', 'entityId': 't1'});
      expect(n.kind, NotificationKind.visit);
      expect(n.screen, 'temple');
      expect(n.entityId, 't1');
      expect(n.hasDestination, isTrue);
    });

    test('unknown type degrades to unknown kind', () {
      expect(_n(type: 'WHATEVER').kind, NotificationKind.unknown);
    });

    test('page parses pagination envelope', () {
      final page = NotificationPage.fromEnvelope({
        'data': [
          {'id': 'a', 'type': 'CARD', 'title': 'T', 'message': 'M', 'isRead': false, 'createdAt': '2026-05-01T10:00:00.000Z'},
        ],
        'pagination': {'page': 2, 'totalPages': 5, 'total': 90},
      });
      expect(page.items, hasLength(1));
      expect(page.page, 2);
      expect(page.hasMore, isTrue);
    });
  });

  group('deep-link resolution', () {
    test('temple / card / route / passport / referral action urls resolve', () {
      expect(resolveDestination(_n(type: 'VISIT', actionUrl: '/temples/somnath'))!.pathParameters.values.first, 'somnath');
      expect(resolveDestination(_n(type: 'CARD', actionUrl: '/cards/abc'))!.pathParameters.values.first, 'abc');
      expect(resolveDestination(_n(type: 'ROUTE', actionUrl: '/routes/char-dham'))!.pathParameters.values.first, 'char-dham');
      expect(resolveDestination(_n(type: 'PASSPORT', actionUrl: '/passport')), isNotNull);
      expect(resolveDestination(_n(type: 'SYSTEM', actionUrl: '/my/referral')), isNotNull);
    });

    test('series/season action urls fall back to the cards hub', () {
      expect(resolveDestination(_n(type: 'CARD', actionUrl: '/cards/series/s1')), isNotNull);
    });

    test('no actionUrl + no known screen resolves to null (stay on detail)', () {
      expect(resolveDestination(_n(type: 'SYSTEM')), isNull);
    });
  });

  group('feed helpers', () {
    test('NotificationFilter.matches gates by kind', () {
      final visit = _n(type: 'VISIT');
      expect(NotificationFilter.all.matches(visit), isTrue);
      expect(NotificationFilter.visits.matches(visit), isTrue);
      expect(NotificationFilter.cards.matches(visit), isFalse);
    });

    test('groupByRecency buckets today vs earlier', () {
      final items = [
        _n(type: 'VISIT', at: DateTime.now()),
        _n(type: 'CARD', at: DateTime.now().subtract(const Duration(days: 20))),
      ];
      final groups = groupByRecency(items);
      expect(groups.first.$1, RecencyBucket.today);
      expect(groups.last.$1, RecencyBucket.earlier);
    });
  });

  test('Festival.daysUntil + Quote.attribution derive correctly', () {
    final f = Festival.fromJson({
      'id': 'f', 'name': 'Holi', 'slug': 'holi',
      'startDate': DateTime.now().add(const Duration(days: 5)).toIso8601String(),
    });
    expect(f.daysUntil, 5);
    expect(f.isToday, isFalse);

    final q = Quote.fromJson({'id': 'q', 'text': 'Faith', 'source': 'BHAGAVAD_GITA', 'reference': '4.39'});
    expect(q.attribution, 'Bhagavad Gita (4.39)');
  });

  testWidgets('NotificationTile shows title, message and an unread dot', (tester) async {
    final n = _n(type: 'ACHIEVEMENT', isRead: false);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: NotificationTile(notification: n, onTap: () {})),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Message'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
