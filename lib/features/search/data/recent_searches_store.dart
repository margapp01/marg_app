import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local, device-only recent searches (max 20, newest first, case-insensitive
/// de-dupe). Every mutation returns the new list so the controller can update
/// state without a re-read.
class RecentSearchesStore {
  const RecentSearchesStore();

  static const _key = 'search.recent';
  static const _max = 20;

  Future<List<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? const [];
  }

  Future<List<String>> add(String term) async {
    final t = term.trim();
    if (t.isEmpty) return load();
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_key) ?? <String>[];
    final next = [
      t,
      ...current.where((e) => e.toLowerCase() != t.toLowerCase()),
    ].take(_max).toList();
    await prefs.setStringList(_key, next);
    return next;
  }

  Future<List<String>> remove(String term) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_key) ?? <String>[];
    final next = current.where((e) => e != term).toList();
    await prefs.setStringList(_key, next);
    return next;
  }

  Future<List<String>> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    return const [];
  }
}

final recentSearchesStoreProvider =
    Provider<RecentSearchesStore>((ref) => const RecentSearchesStore());
