import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// User-controlled Yansi memory. Stores structured records separately from
/// the UI so the same memory can later be synchronized to a cloud database.
class YansiMemoryStore {
  static const _key = 'yansi_structured_memory';

  final SharedPreferences prefs;

  const YansiMemoryStore(this.prefs);

  Future<void> remember({
    required String type,
    required String text,
    String source = 'user',
    Map<String, dynamic> attributes = const {},
  }) async {
    final rows = prefs.getStringList(_key) ?? <String>[];
    rows.add(jsonEncode({
      'id': DateTime.now().microsecondsSinceEpoch.toString(),
      'type': type,
      'text': text,
      'source': source,
      'createdAt': DateTime.now().toIso8601String(),
      'attributes': attributes,
    }));
    await prefs.setStringList(_key, rows);
  }

  List<Map<String, dynamic>> readAll() {
    final rows = prefs.getStringList(_key) ?? <String>[];
    final result = <Map<String, dynamic>>[];
    for (final row in rows) {
      try {
        final value = jsonDecode(row);
        if (value is Map<String, dynamic>) result.add(value);
      } catch (_) {}
    }
    return result;
  }

  Future<void> clear() => prefs.remove(_key);
}
