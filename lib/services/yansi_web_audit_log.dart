import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Local, privacy-conscious audit trail for user-approved web lookups.
/// Query text is intentionally not persisted.
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

  Future<void> record({required String provider, required String source}) async {
    final p = provider.trim();
    final s = source.trim();
    if (p.isEmpty || s.isEmpty) return;

    final raw = prefs.getStringList(_key) ?? <String>[];
    raw.add(jsonEncode({
      'provider': p,
      'source': s,
      'date': DateTime.now().toIso8601String(),
    }));
    if (raw.length > 50) raw.removeRange(0, raw.length - 50);
    await prefs.setStringList(_key, raw);
  }

  Future<void> clear() => prefs.remove(_key);
}
