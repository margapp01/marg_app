import 'package:flutter_test/flutter_test.dart';
import 'package:marg_app/features/search/domain/entities/search_models.dart';

void main() {
  group('SearchResults.fromJson', () {
    Map<String, dynamic> payload() => {
          'query': 'ka',
          'total': 3,
          'results': {
            'temples': [
              {'type': 'temple', 'id': 't2', 'title': 'Somnath', 'slug': 'somnath', 'subtitle': 'Gujarat'},
              {'type': 'temple', 'id': 't1', 'title': 'Kashi', 'slug': 'kashi', 'subtitle': 'Varanasi'},
            ],
            'blogs': [
              {'type': 'blog', 'id': 'b1', 'title': 'Guide', 'slug': 'guide', 'subtitle': 'Guides'},
            ],
            'cities': [
              {'type': 'city', 'id': 'c1', 'title': 'Varanasi'},
            ],
          },
        };

    test('groups in display order and totals every rendered group', () {
      final r = SearchResults.fromJson(payload());
      // Temples first, then places (so "Ujjain" finds the city), then blogs.
      expect(r.groups.map((g) => g.type).toList(), [SearchType.temple, SearchType.city, SearchType.blog]);
      expect(r.total, 4);
      expect(r.isEmpty, isFalse);
    });

    test('a place-only result is not empty', () {
      final r = SearchResults.fromJson(const <String, dynamic>{
        'query': 'Ujjain',
        'results': <String, dynamic>{
          'cities': [
            {'type': 'city', 'id': 'c9', 'title': 'Ujjain', 'subtitle': 'Madhya Pradesh'},
          ],
        },
      });
      expect(r.isEmpty, isFalse);
      expect(r.groups.single.type, SearchType.city);
    });

    test('server order preserved for relevance sort', () {
      final r = SearchResults.fromJson(payload());
      expect(r.groups.first.hits.map((h) => h.title).toList(), ['Somnath', 'Kashi']);
    });

    test('alphabetical sort orders hits A→Z', () {
      final r = SearchResults.fromJson(payload(), sort: SearchSort.alphabetical);
      expect(r.groups.first.hits.map((h) => h.title).toList(), ['Kashi', 'Somnath']);
    });

    test('empty payload yields no groups', () {
      final r = SearchResults.fromJson(const <String, dynamic>{'query': 'x', 'results': <String, dynamic>{}});
      expect(r.groups, isEmpty);
      expect(r.isEmpty, isTrue);
    });
  });
}
