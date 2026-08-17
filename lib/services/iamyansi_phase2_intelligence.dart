import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Non-visual Phase 2 intelligence layer for iamyansi.
class IamyansiPhase2Intelligence {
  static const String _taskKey = 'iamyansi_tasks';
  static const String _maintenanceKey = 'iamyansi_phase2_last_maintenance';
  static const String _insightKey = 'iamyansi_phase2_daily_insights';

  final SharedPreferences prefs;

  const IamyansiPhase2Intelligence({required this.prefs});

  Future<void> runDailyMaintenance({DateTime? now}) async {
    final today = _dateOnly(now ?? DateTime.now());
    final todayKey = _key(today);
    if (prefs.getString(_maintenanceKey) == todayKey) return;

    final tasks = _read(_taskKey);
    final additions = <Map<String, dynamic>>[];
    for (final task in tasks) {
      if (task['completed'] == true) continue;
      final date = DateTime.tryParse('${task['date'] ?? ''}');
      if (date == null || !_dateOnly(date).isBefore(today)) continue;
      final sourceId = '${task['id'] ?? ''}';
      final exists = tasks.any((candidate) =>
          candidate['carriedFrom']?.toString() == sourceId && candidate['dateKey'] == todayKey);
      if (exists) continue;
      additions.add({
        'id': '${DateTime.now().microsecondsSinceEpoch}_$sourceId:$todayKey',
        'type': 'task',
        'task': '${task['task'] ?? 'Pending task'}',
        'completed': false,
        'source': 'iamyansi_carry_forward',
        'carriedFrom': sourceId,
        'originalDate': date.toIso8601String(),
        'date': today.toIso8601String(),
        'dateKey': todayKey,
      });
    }
    if (additions.isNotEmpty) {
      final raw = prefs.getStringList(_taskKey) ?? <String>[];
      raw.addAll(additions.map(jsonEncode));
      await prefs.setStringList(_taskKey, raw);
    }
    await prefs.setString(_maintenanceKey, todayKey);
  }

  Future<void> saveDailyInsight(String text, {DateTime? now}) async {
    final value = text.trim();
    if (value.isEmpty) return;
    final key = _key(_dateOnly(now ?? DateTime.now()));
    final raw = prefs.getStringList(_insightKey) ?? <String>[];
    raw.removeWhere((entry) {
      try { return jsonDecode(entry)['dateKey'] == key; } catch (_) { return false; }
    });
    raw.add(jsonEncode({'dateKey': key, 'text': value, 'source': 'iamyansi'}));
    if (raw.length > 30) raw.removeRange(0, raw.length - 30);
    await prefs.setStringList(_insightKey, raw);
  }

  List<Map<String, dynamic>> _read(String key) => (prefs.getStringList(key) ?? <String>[])
      .map((value) { try { return Map<String, dynamic>.from(jsonDecode(value) as Map); } catch (_) { return <String, dynamic>{}; } })
      .where((item) => item.isNotEmpty).toList();

  DateTime _dateOnly(DateTime value) => DateTime(value.year, value.month, value.day);
  String _key(DateTime value) => '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
}
