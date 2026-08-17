import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Phase 2 local intelligence layer for iamyansi.
///
/// iamyansi is deliberately non-visual: it remains an ambient/ghost
/// intelligence rather than becoming another screen or core.
class IamyansiPhase2Intelligence {
  static const String _taskKey = 'iamyansi_tasks';
  static const String _maintenanceKey = 'iamyansi_phase2_last_maintenance';
  static const String _insightKey = 'iamyansi_phase2_daily_insights';

  final SharedPreferences prefs;

  const IamyansiPhase2Intelligence({required this.prefs});

  Future<void> runDailyMaintenance({DateTime? now}) async {
    final today = _dateOnly(now ?? DateTime.now());
    final lastRun = prefs.getString(_maintenanceKey);
    final todayKey = _key(today);
    if (lastRun == todayKey) return;

    final tasks = _read(_taskKey);
    final additions = <Map<String, dynamic>>[];

    for (final task in tasks) {
      if (task['completed'] == true) continue;
      final originalDate = DateTime.tryParse((task['date'] ?? '').toString());
      if (originalDate == null) continue;
      if (!_dateOnly(originalDate).isBefore(today)) continue;

      final sourceId = (task['id'] ?? '').toString();
      final alreadyCarried = tasks.any(
        (candidate) => candidate['type'] == 'task' &&
            candidate['carriedFrom']?.toString() == sourceId &&
            candidate['dateKey']?.toString() == todayKey,
      );
      if (alreadyCarried) continue;

      additions.add({
        'id': '${DateTime.now().microsecondsSinceEpoch}_$sourceId:$todayKey',
        'type': 'task',
        'task': (task['task'] ?? 'Pending task').toString(),
        'completed': false,
        'source': 'phase2_carry_forward',
        'carriedFrom': sourceId,
        'originalDate': originalDate.toIso8601String(),
        'date': today.toIso8601String(),
        'dateKey': todayKey,
        'carryForwardCount': ((task['carryForwardCount'] as num?)?.toInt() ?? 0) + 1,
      });
    }

    if (additions.isNotEmpty) {
      final raw = prefs.getStringList(_taskKey) ?? <String>[];
      raw.addAll(additions.map(jsonEncode));
      await prefs.setStringList(_taskKey, raw);
    }

    await prefs.setString(_maintenanceKey, todayKey);
  }

  Map<String, dynamic> snapshot({DateTime? now}) {
    final today = _dateOnly(now ?? DateTime.now());
    final tasks = _read(_taskKey);
    final todayTasks = tasks.where((task) {
      final date = DateTime.tryParse((task['date'] ?? '').toString());
      return date != null && _dateOnly(date) == today;
    }).toList();

    final openToday = todayTasks.where((task) => task['completed'] != true).length;
    final completedToday = todayTasks.where((task) => task['completed'] == true).length;
    final carriedToday = todayTasks.where((task) => task['source'] == 'phase2_carry_forward').length;

    return {
      'todayTaskCount': todayTasks.length,
      'openTaskCount': openToday,
      'completedTaskCount': completedToday,
      'carriedForwardCount': carriedToday,
      'completionPercent': todayTasks.isEmpty ? 0 : ((completedToday / todayTasks.length) * 100).round(),
    };
  }

  Future<void> saveDailyInsight(String text, {DateTime? now}) async {
    final value = text.trim();
    if (value.isEmpty) return;

    final today = _key(_dateOnly(now ?? DateTime.now()));
    final raw = prefs.getStringList(_insightKey) ?? <String>[];
    raw.removeWhere((entry) {
      try {
        final item = Map<String, dynamic>.from(jsonDecode(entry) as Map);
        return item['dateKey'] == today;
      } catch (_) {
        return false;
      }
    });

    raw.add(jsonEncode({
      'dateKey': today,
      'text': value,
      'date': DateTime.now().toIso8601String(),
      'source': 'iamyansi_phase2',
    }));

    if (raw.length > 30) raw.removeRange(0, raw.length - 30);
    await prefs.setStringList(_insightKey, raw);
  }

  List<Map<String, dynamic>> _read(String key) {
    final raw = prefs.getStringList(key) ?? <String>[];
    return raw.map((value) {
      try {
        return Map<String, dynamic>.from(jsonDecode(value) as Map);
      } catch (_) {
        return <String, dynamic>{};
      }
    }).where((item) => item.isNotEmpty).toList();
  }

  DateTime _dateOnly(DateTime value) => DateTime(value.year, value.month, value.day);

  String _key(DateTime value) => '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
}
