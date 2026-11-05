import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marg_app/app/localization/app_localizations.dart';
import 'package:marg_app/app/theme/app_theme.dart';
import 'package:marg_app/features/knowledge/data/repository/knowledge_repository.dart';
import 'package:marg_app/features/knowledge/domain/entities/knowledge_models.dart';
import 'package:marg_app/features/knowledge/presentation/widgets/knowledge_reading.dart';
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

  test('storiesForFestival matches tags against the festival name and its words', () {
    Blog blog(String slug, List<String> tags) => Blog.fromJson({'id': slug, 'title': slug, 'slug': slug, 'tags': tags});
    final blogs = [
      blog('guide', ['Diwali', 'Bhai Dooj']),
      blog('chhath', ['Puja', 'Surya']),
      blog('navratri', ['Navratri']),
    ];
    expect(storiesForFestival('Diwali', blogs).map((b) => b.slug), ['guide']);
    expect(storiesForFestival('Bhai Dooj', blogs).map((b) => b.slug), ['guide']);
    expect(storiesForFestival('Chaitra Navratri', blogs).map((b) => b.slug), ['navratri']);
    expect(storiesForFestival('Govardhan Puja', blogs).map((b) => b.slug), ['chhath'], reason: 'a bare "Puja" tag matches every "X Puja"');
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

    test('reads a figure as an image with its caption', () {
      final blocks = parseHtmlBlocks(
        '<p>Lamps.</p><figure><img src="https://x/diya.jpg" alt="A diya">'
        '<figcaption>A diya. Photo: <a href="https://c/f">Commons</a></figcaption></figure><p>After.</p>',
      );
      expect(blocks.map((b) => b.tag).toList(), ['p', 'img', 'p']);
      expect(blocks[1].src, 'https://x/diya.jpg');
      expect(blocks[1].text, 'A diya. Photo: <a href="https://c/f">Commons</a>');
    });

    test('reads admin plain text as paragraphs, bullet lists and bold', () {
      final blocks = parseHtmlBlocks(
        'Diwali is the **festival of lights** & more.\nIt lasts five days.\n\n'
        'The five days:\n• Dhanteras: 6 Nov\n- Bhai Dooj: 11 Nov\n\nConfirm with your temple.',
      );
      expect(blocks.map((b) => b.tag).toList(), ['p', 'p', 'ul', 'p']);
      expect(blocks[0].text, 'Diwali is the <b>festival of lights</b> &amp; more. It lasts five days.');
      expect(blocks[2].items, ['Dhanteras: 6 Nov', 'Bhai Dooj: 11 Nov']);
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
