import '../entities/temple_detail.dart';

/// Loads the full Temple Detail bundle (temple + intelligence + user status +
/// nearby) for a slug, composing several endpoints fail-soft.
abstract interface class TempleDetailRepository {
  Future<TempleDetailBundle> loadBundle(String slug);
}
