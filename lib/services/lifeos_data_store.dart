import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Local-first LifeOS data layer.
///
/// Every record has a stable id, type and timestamp. This keeps the app
/// usable offline today and gives us a clean seam for cloud synchronisation
/// later. Do not put passwords or authentication secrets in this store.
class LifeOSDataStore {
  final SharedPreferences prefs;

  const LifeOSDataStore(this.prefs);

  Future<void> append(String collection, Map<String, dynamic> record) async {
    final rows = prefs.getStringList(_key(collection)) ?? <String>[];
    rows.add(jsonEncode(record));
    await prefs.setStringList(_key(collection), rows);
  }

  List<Map<String, dynamic>> read(String collection) {
    final rows = prefs.getStringList(_key(collection)) ?? <String>[];
    final result = <Map<String, dynamic>>[];
    for (final row in rows) {
      try {
        final decoded = jsonDecode(row);
        if (decoded is Map<String, dynamic>) result.add(decoded);
      } catch (_) {}
    }
    return result;
  }

  Future<void> replace(
    String collection,
    List<Map<String, dynamic>> records,
  ) async {
    await prefs.setStringList(
      _key(collection),
      records.map(jsonEncode).toList(),
    );
  }

  Future<void> clear(String collection) async {
    await prefs.remove(_key(collection));
  }

  String _key(String collection) => 'lifeos_collection_$collection';
}

/// Contract for the future cloud database implementation.
///
/// Firebase/Supabase can implement this without changing the LifeOS UI or
/// Yansi intelligence layer. The first production implementation should use
/// the authenticated user's id as the data partition and enforce server-side
/// access rules.
abstract class LifeOSCloudStore {
  Future<void> upsert(String userId, String collection, String id,
      Map<String, dynamic> data);

  Future<List<Map<String, dynamic>>> read(
      String userId, String collection);

  Future<void> delete(String userId, String collection, String id);
}
