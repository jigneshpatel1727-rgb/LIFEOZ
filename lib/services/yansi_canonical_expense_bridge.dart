import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Synchronizes Yansi voice expenses with the canonical Expense core store.
/// The sync is idempotent: an expense ID is never imported twice.
class YansiCanonicalExpenseBridge {
  static const String yansiKey = 'yansi_expenses';
  static const String canonicalKey = 'lifeos_expenses';

  final SharedPreferences prefs;

  const YansiCanonicalExpenseBridge({required this.prefs});

  Future<int> sync() async {
    final sources = _readStringList(yansiKey);
    if (sources.isEmpty) return 0;

    final canonical = _readCanonical();
    final ids = canonical
        .map((r) => r['id']?.toString())
        .whereType<String>()
        .toSet();

    var added = 0;
    for (final source in sources) {
      final id = source['id']?.toString();
      if (id == null || id.isEmpty || ids.contains(id)) continue;

      final amount = (source['amount'] as num?)?.toDouble();
      if (amount == null) continue;

      final category = (source['category'] ?? 'Other').toString();
      final title = (source['title'] ?? source['text'] ?? category).toString();
      final date = source['date']?.toString() ?? DateTime.now().toIso8601String();

      canonical.add({
        'id': id,
        'title': title,
        'category': category,
        'amount': amount,
        'date': date,
      });
      ids.add(id);
      added++;
    }

    if (added > 0) {
      await prefs.setString(canonicalKey, jsonEncode(canonical));
    }
    return added;
  }

  List<Map<String, dynamic>> _readStringList(String key) {
    final raw = prefs.getStringList(key) ?? <String>[];
    return raw.map((value) {
      try {
        return Map<String, dynamic>.from(jsonDecode(value) as Map);
      } catch (_) {
        return <String, dynamic>{};
      }
    }).where((item) => item.isNotEmpty).toList();
  }

  List<Map<String, dynamic>> _readCanonical() {
    final raw = prefs.getString(canonicalKey);
    if (raw == null || raw.isEmpty) return <Map<String, dynamic>>[];
    try {
      final decoded = jsonDecode(raw) as List;
      return decoded
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    } catch (_) {
      return <Map<String, dynamic>>[];
    }
  }
}
