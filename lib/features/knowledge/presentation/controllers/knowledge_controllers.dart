import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repository/knowledge_repository.dart';
import '../../domain/entities/knowledge_models.dart';

/// All Knowledge Hub reads. Each is `autoDispose` so leaving a screen frees the
/// request, and screens compose several in parallel via their own `.when`.

final knowledgeBlogsProvider = FutureProvider.autoDispose<List<Blog>>(
  (ref) => ref.watch(knowledgeRepositoryProvider).blogs(),
);

/// Distinct blog categories, derived from the loaded blogs (no taxonomy API).
final knowledgeCategoriesProvider = FutureProvider.autoDispose<List<String>>(
  (ref) async => KnowledgeRepository.categoriesOf(await ref.watch(knowledgeBlogsProvider.future)),
);

final blogDetailProvider = FutureProvider.autoDispose.family<Blog, String>(
  (ref, slug) => ref.watch(knowledgeRepositoryProvider).blog(slug),
);

final relatedBlogsProvider = FutureProvider.autoDispose.family<List<Blog>, String>(
  (ref, slug) async {
    final repo = ref.watch(knowledgeRepositoryProvider);
    final blog = await ref.watch(blogDetailProvider(slug).future);
    return repo.related(blog);
  },
);

final blogSearchProvider = FutureProvider.autoDispose.family<List<Blog>, String>(
  (ref, query) {
    final q = query.trim();
    if (q.length < 2) return Future.value(const <Blog>[]);
    return ref.watch(knowledgeRepositoryProvider).searchBlogs(q);
  },
);

final announcementsProvider = FutureProvider.autoDispose<List<Announcement>>(
  (ref) => ref.watch(knowledgeRepositoryProvider).announcements(),
);

final knowledgeFaqsProvider = FutureProvider.autoDispose<List<Faq>>(
  (ref) => ref.watch(knowledgeRepositoryProvider).faqs(),
);

final knowledgeBannersProvider = FutureProvider.autoDispose<List<KnowledgeBanner>>(
  (ref) => ref.watch(knowledgeRepositoryProvider).banners(),
);

final dailyQuoteProvider = FutureProvider.autoDispose<Quote?>(
  (ref) => ref.watch(knowledgeRepositoryProvider).dailyQuote(),
);

final upcomingFestivalsProvider = FutureProvider.autoDispose<List<Festival>>(
  (ref) => ref.watch(knowledgeRepositoryProvider).upcomingFestivals(),
);

final festivalDetailProvider = FutureProvider.autoDispose.family<Festival, String>(
  (ref, slug) => ref.watch(knowledgeRepositoryProvider).festival(slug),
);

final staticPageProvider = FutureProvider.autoDispose.family<StaticPage, PageKind>(
  (ref, kind) => ref.watch(knowledgeRepositoryProvider).staticPage(kind),
);
