import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Permanent local memory for Yansi's approved web interactions.
/// A personal AI retains approved search history as long-term context.
class YansiWebAuditLog {
  static const _key = 'yansi_web_audit_log';
  final SharedPreferences prefs;

  const YansiWebAuditLog({required this.prefs});

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

  Future<void> record({
    required String provider,
    required String source,
    required String query,
  }) async {
    final p = provider.trim();
    final s = source.trim();
    final q = query.trim();
    if (p.isEmpty || s.isEmpty || q.isEmpty) return;

    final raw = prefs.getStringList(_key) ?? <String>[];
    raw.add(jsonEncode({
      'provider': p,
      'source': s,
      'query': q,
      'date': DateTime.now().toIso8601String(),
    }));
    await prefs.setStringList(_key, raw);
  }
}
