import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Stores bounded, explainable behavioral patterns derived from repeated outcomes.
/// Runtime memory only: it never rewrites code or changes permissions.
class YansiLongTermPatternMemory {
  final SharedPreferences prefs;
  const YansiLongTermPatternMemory({required this.prefs});

  static const _key = 'yansi_long_term_patterns';
  static const _limit = 100;

  Future<void> observe({
    required String patternKey,
    required String core,
    required String signal,
    required String outcome,
  }) async {
    final key = patternKey.trim();
    if (key.isEmpty) return;
    final records = _read();
    final index = records.indexWhere((e) => e['patternKey'] == key);
    final now = DateTime.now().toUtc().toIso8601String();
    if (index < 0) {
      records.add({
        'patternKey': key,
        'core': core,
        'signal': signal,
        'observations': 1,
        'positive': outcome == 'accepted' || outcome == 'acted',
        'negative': outcome == 'dismissed' || outcome == 'ignored',
        'lastOutcome': outcome,
        'lastSeen': now,
      });
    } else {
      final item = records[index];
      item['observations'] = ((item['observations'] as num?)?.toInt() ?? 0) + 1;
      if (outcome == 'accepted' || outcome == 'acted') item['positive'] = true;
      if (outcome == 'dismissed' || outcome == 'ignored') item['negative'] = true;
      item['lastOutcome'] = outcome;
      item['lastSeen'] = now;
    }
    final bounded = records.length > _limit ? records.sublist(records.length - _limit) : records;
    await prefs.setString(_key, jsonEncode(bounded));
  }

  List<Map<String, dynamic>> reliable({int minimumObservations = 3}) {
    return _read().where((e) => ((e['observations'] as num?)?.toInt() ?? 0) >= minimumObservations).toList();
  }

  List<Map<String, dynamic>> _read() {
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return <Map<String, dynamic>>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return <Map<String, dynamic>>[];
      return decoded.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (_) {
      return <Map<String, dynamic>>[];
    }
  }
}
