import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Records the outcome of an authorized Yansi action without executing it.
/// Keeps a bounded local history for explainability and recovery decisions.
class YansiExecutionAudit {
  final SharedPreferences prefs;
  const YansiExecutionAudit({required this.prefs});

  static const _key = 'yansi_execution_audit';
  static const _limit = 50;

  Future<void> record({
    required String proposalId,
    required String action,
    required bool authorized,
    required bool executed,
    required String outcome,
    String? error,
  }) async {
    final entries = _read();
    entries.add({
      'proposalId': proposalId,
      'action': action,
      'authorized': authorized,
      'executed': executed,
      'outcome': outcome,
      'error': error,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    });
    final bounded = entries.length > _limit
        ? entries.sublist(entries.length - _limit)
        : entries;
    await prefs.setString(_key, jsonEncode(bounded));
  }

  List<Map<String, dynamic>> recent({int limit = 10}) {
    final entries = _read();
    final safeLimit = limit.clamp(1, _limit);
    return entries.length <= safeLimit
        ? entries.reversed.toList()
        : entries.sublist(entries.length - safeLimit).reversed.toList();
  }

  Map<String, dynamic>? find(String proposalId) {
    for (final entry in _read().reversed) {
      if ('${entry['proposalId'] ?? ''}' == proposalId) return entry;
    }
    return null;
  }

  List<Map<String, dynamic>> _read() {
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return <Map<String, dynamic>>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return <Map<String, dynamic>>[];
      return decoded
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } catch (_) {
      return <Map<String, dynamic>>[];
    }
  }
}
