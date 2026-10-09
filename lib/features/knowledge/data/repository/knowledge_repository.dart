import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/knowledge_models.dart';
import '../datasource/knowledge_remote_datasource.dart';

/// Coordinates the Knowledge Hub reads. Mostly a passthrough over the remote
/// data source; the only logic here is honest client-side derivation the
/// backend doesn't expose (distinct categories, "related" by shared category).
class KnowledgeRepository {
  KnowledgeRepository(this._remote);
  final KnowledgeRemoteDataSource _remote;

  Future<List<Blog>> blogs({int limit = 50}) => _remote.blogs(limit: limit);
  Future<Blog> blog(String slug) => _remote.blog(slug);
  Future<List<Blog>> searchBlogs(String q) => _remote.searchBlogs(q);
  Future<List<Announcement>> announcements() => _remote.announcements();
  Future<List<Faq>> faqs() => _remote.faqs();
  Future<List<KnowledgeBanner>> banners() => _remote.banners();
  Future<Quote?> dailyQuote() => _remote.dailyQuote();
  Future<List<Festival>> upcomingFestivals() => _remote.upcomingFestivals();
  Future<Festival> festival(String slug) => _remote.festival(slug);
  Future<StaticPage> staticPage(PageKind kind) => _remote.staticPage(kind);

  /// Distinct, non-empty blog categories in first-seen (newest-first) order —
  /// derived from the returned blogs, never a hardcoded taxonomy.
  static List<String> categoriesOf(List<Blog> blogs) {
    final seen = <String>{};
    final out = <String>[];
    for (final b in blogs) {
      final c = b.category;
      if (c != null && c.isNotEmpty && seen.add(c)) out.add(c);
    }
    return out;
  }

  /// Up to [max] other published blogs sharing [blog]'s category — an honest
  /// "related" derivation (the backend has no relatedness data).
  Future<List<Blog>> related(Blog blog, {int max = 4}) async {
    final category = blog.category;
    if (category == null || category.isEmpty) return const [];
    final all = await _remote.blogs(limit: 50);
    return all.where((b) => b.slug != blog.slug && b.category == category).take(max).toList(growable: false);
  }
}

final knowledgeRepositoryProvider = Provider<KnowledgeRepository>(
  (ref) => KnowledgeRepository(ref.watch(knowledgeRemoteDataSourceProvider)),
);
