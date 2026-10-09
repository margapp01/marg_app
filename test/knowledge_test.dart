import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marg_app/app/localization/app_localizations.dart';
import 'package:marg_app/app/theme/app_theme.dart';
import 'package:marg_app/features/knowledge/data/repository/knowledge_repository.dart';
import 'package:marg_app/features/knowledge/domain/entities/knowledge_models.dart';
import 'package:marg_app/features/knowledge/presentation/widgets/knowledge_widgets.dart';
import 'package:marg_app/shared/content/html_content_view.dart';

void main() {
  group('Blog', () {
    test('parses the /cms/blogs contract and derives reading time', () {
      final b = Blog.fromJson({
        'id': 'b1',
        'title': 'Kedarnath: The Abode of Lord Shiva',
        'slug': 'kedarnath',
        'category': 'Temples',
        'tags': const ['shiva', 'himalaya'],
        'coverImageUrl': 'https://x/cover.jpg',
        'excerpt': 'One of the twelve Jyotirlingas.',
        'contentHtml': '<p>${'word ' * 400}</p>',
        'publishAt': '2024-05-20T00:00:00.000Z',
      });
      expect(b.slug, 'kedarnath');
      expect(b.tags, hasLength(2));
      expect(b.publishedAt, DateTime.utc(2024, 5, 20));
      expect(b.readingMinutes, 2); // ~400 words / 200 wpm
    });

    test('falls back to createdAt and a 1-minute minimum read', () {
      final b = Blog.fromJson(const {'id': 'b2', 'title': 'T', 'slug': 's', 'createdAt': '2024-01-01T00:00:00.000Z'});
      expect(b.publishedAt, DateTime.utc(2024, 1, 1));
      expect(b.readingMinutes, 1);
    });
  });

  test('Announcement maps kind wire values, defaulting unknown', () {
    expect(announcementKindFromWire('EMERGENCY'), AnnouncementKind.emergency);
    expect(announcementKindFromWire('MAINTENANCE'), AnnouncementKind.maintenance);
    expect(announcementKindFromWire('WAT'), AnnouncementKind.unknown);
    final a = Announcement.fromJson(const {'id': 'a1', 'kind': 'FESTIVAL', 'title': 'Rath Yatra', 'body': 'Soon', 'pinned': true});
    expect(a.kind, AnnouncementKind.festival);
    expect(a.pinned, isTrue);
  });

  test('categoriesOf returns distinct non-empty categories in order', () {
    final blogs = [
      Blog.fromJson(const {'id': '1', 'title': 'a', 'slug': 'a', 'category': 'Temples'}),
      Blog.fromJson(const {'id': '2', 'title': 'b', 'slug': 'b', 'category': 'Yatra'}),
      Blog.fromJson(const {'id': '3', 'title': 'c', 'slug': 'c', 'category': 'Temples'}),
      Blog.fromJson(const {'id': '4', 'title': 'd', 'slug': 'd', 'category': ''}),
    ];
    expect(KnowledgeRepository.categoriesOf(blogs), ['Temples', 'Yatra']);
  });

  group('parseHtmlBlocks', () {
    test('splits headings, paragraphs, lists and images in order', () {
      final blocks = parseHtmlBlocks(
        '<h2>Significance</h2><p>It is <strong>believed</strong> to destroy sins.</p>'
        '<ul><li>First</li><li>Second</li></ul><img src="https://x/a.jpg" alt="a">',
      );
      expect(blocks.map((b) => b.tag).toList(), ['h2', 'p', 'ul', 'img']);
      expect(blocks[2].items, ['First', 'Second']);
      expect(blocks[3].src, 'https://x/a.jpg');
    });

    test('wraps loose text with no block tags into a paragraph', () {
      final blocks = parseHtmlBlocks('Just some plain sentence.');
      expect(blocks, hasLength(1));
      expect(blocks.first.tag, 'p');
    });
  });

  testWidgets('BlogListTile renders title and estimated read time', (tester) async {
    final blog = Blog.fromJson({
      'id': 'b1',
      'title': 'The Power of Mantra Chanting',
      'slug': 'mantra',
      'contentHtml': '<p>${'word ' * 200}</p>',
    });
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: BlogListTile(blog: blog, onTap: () {})),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('The Power of Mantra Chanting'), findsOneWidget);
    expect(find.textContaining('min read'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
