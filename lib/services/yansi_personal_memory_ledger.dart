import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Append-only long-term memory for Yansi's personal context.
///
/// This ledger is intentionally broader than web history: approved voice/text
/// interactions, searches, observations, decisions, records and outcomes can
/// all become durable context. It never trims entries and exposes no delete
/// operation. Sensitive execution remains protected by the application's
/// existing confirmation/permission boundaries.
class YansiPersonalMemoryLedger {
  static const _key = 'yansi_personal_memory_ledger';

  final SharedPreferences prefs;

  const YansiPersonalMemoryLedger({required this.prefs});

  List<Map<String, dynamic>> entries() {
    return (prefs.getStringList(_key) ?? const <String>[]).map((raw) {
      try {
        final value = jsonDecode(raw);
        return value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};
      } catch (_) {
        return <String, dynamic>{};
      }
    }).where((entry) => entry.isNotEmpty).toList(growable: false);
  }

  Future<void> remember({
    required String type,
    required String content,
    Map<String, dynamic> context = const {},
  }) async {
    final normalizedType = type.trim();
    final normalizedContent = content.trim();
    if (normalizedType.isEmpty || normalizedContent.isEmpty) return;

    final raw = prefs.getStringList(_key) ?? <String>[];
    raw.add(jsonEncode({
      'id': DateTime.now().microsecondsSinceEpoch.toString(),
      'type': normalizedType,
      'content': normalizedContent,
      'context': context,
      'date': DateTime.now().toIso8601String(),
    }));
    await prefs.setStringList(_key, raw);
  }

  List<Map<String, dynamic>> find(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return entries();
    return entries().where((entry) {
      final content = '${entry['content'] ?? ''} ${entry['type'] ?? ''}'.toLowerCase();
      return content.contains(q);
    }).toList(growable: false);
  }

  int get count => entries().length;
}
