import 'package:drift/drift.dart';

/// A generic key→JSON cache row backing the offline read-through cache. One row
/// per cached endpoint payload (e.g. `home_dashboard`, `temple_detail:<slug>`).
class CacheEntries extends Table {
  /// Stable cache key for the payload.
  TextColumn get key => text()();

  /// The raw JSON payload (a `data` object/array), encoded as a string.
  TextColumn get payload => text()();

  /// When this payload was last written from the network.
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {key};
}
