import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Builds a compact, explainable context snapshot from permitted LifeOS memory.
/// This layer is local-first: it does not invent facts and does not execute actions.
class YansiContextSnapshot {
  final DateTime createdAt;
  final int openTasks, upcomingReminders, expenseRecords, householdRecords, goals, diaryEntries;
  final double recentSpend;
  final List<String> recentThemes;
  final String focus;

  const YansiContextSnapshot({
    required this.createdAt,
    required this.openTasks,
    required this.upcomingReminders,
    required this.expenseRecords,
    required this.householdRecords,
    required this.goals,
    required this.diaryEntries,
    required this.recentSpend,
    required this.recentThemes,
    required this.focus,
  });

  Map<String, dynamic> toJson() => {
        'createdAt': createdAt.toIso8601String(),
        'openTasks': openTasks,
        'upcomingReminders': upcomingReminders,
        'expenseRecords': expenseRecords,
        'householdRecords': householdRecords,
        'goals': goals,
        'diaryEntries': diaryEntries,
        'recentSpend': recentSpend,
        'recentThemes': recentThemes,
        'focus': focus,
      };

  String get summary =>
      'Open tasks: $openTasks. Upcoming reminders: $upcomingReminders. '
      'Recent spending: $recentSpend. Goals: $goals. '
      'Household records: $householdRecords. Current focus: $focus.';
}

class YansiContextFusion {
  final SharedPreferences prefs;
  const YansiContextFusion({required this.prefs});

  List<Map<String, dynamic>> _read(String key) {
    final raw = prefs.getStringList(key) ?? const <String>[];
    return raw
        .map((v) {
          try {
            return Map<String, dynamic>.from(jsonDecode(v) as Map);
          } catch (_) {
            return <String, dynamic>{};
          }
        })
        .where((e) => e.isNotEmpty)
        .toList();
  }

  List<Map<String, dynamic>> _readMerged(String primary, String legacy) {
    final records = <Map<String, dynamic>>[..._read(primary)];
    final legacyRaw = prefs.getString(legacy);
    if (legacyRaw != null && legacyRaw.isNotEmpty) {
      try {
        final decoded = jsonDecode(legacyRaw);
        if (decoded is List) {
          for (final item in decoded) {
            if (item is Map) records.add(Map<String, dynamic>.from(item));
          }
        }
      } catch (_) {}
    }
    return records;
  }

  Future<YansiContextSnapshot> build() async {
    final now = DateTime.now();
    final tasks = _read('yansi_tasks');
    final reminders = _read('yansi_reminders');
    final expenses = _readMerged('yansi_expenses', 'lifeos_expenses');
    final household = _read('yansi_household');
    final goals = _read('yansi_goals');
    final diary = _read('yansi_diary');

    final openTasks = tasks.where((e) => e['completed'] != true).length;
    final upcoming = reminders.where((e) {
      final d = DateTime.tryParse('${e['dueDate'] ?? e['date'] ?? ''}');
      return d != null && !d.isBefore(now) && d.isBefore(now.add(const Duration(days: 14)));
    }).length;

    double spend = 0;
    for (final e in expenses) {
      final d = DateTime.tryParse('${e['date'] ?? ''}');
      if (d != null && !d.isAfter(now) && now.difference(d).inDays <= 30) {
        spend += (e['amount'] as num?)?.toDouble() ?? 0;
      }
    }

    final themes = <String>[];
    final configuredFocus = prefs.getString('yansi_active_focus');
    final legacyFocus = prefs.getString('yansi_focus_mode');
    final focus = (configuredFocus ?? legacyFocus)?.trim().toLowerCase();
    if (openTasks > 0) themes.add('productivity');
    if (upcoming > 0) themes.add('calendar');
    if (spend > 0) themes.add('money');
    if (goals.isNotEmpty) themes.add('goals');
    if (household.isNotEmpty) themes.add('household');
    if (diary.isNotEmpty) themes.add('personal memory');

    final selected = (focus == null || focus.isEmpty)
        ? (themes.isEmpty ? 'ambient' : themes.first)
        : focus;
    final snapshot = YansiContextSnapshot(
      createdAt: now,
      openTasks: openTasks,
      upcomingReminders: upcoming,
      expenseRecords: expenses.length,
      householdRecords: household.length,
      goals: goals.length,
      diaryEntries: diary.length,
      recentSpend: double.parse(spend.toStringAsFixed(2)),
      recentThemes: themes,
      focus: selected,
    );

    await prefs.setString('yansi_context_snapshot', jsonEncode(snapshot.toJson()));
    return snapshot;
  }

  YansiContextSnapshot? last() {
    final raw = prefs.getString('yansi_context_snapshot');
    if (raw == null) return null;
    try {
      final m = jsonDecode(raw) as Map;
      return YansiContextSnapshot(
        createdAt: DateTime.tryParse('${m['createdAt']}') ?? DateTime.now(),
        openTasks: (m['openTasks'] as num?)?.toInt() ?? 0,
        upcomingReminders: (m['upcomingReminders'] as num?)?.toInt() ?? 0,
        expenseRecords: (m['expenseRecords'] as num?)?.toInt() ?? 0,
        householdRecords: (m['householdRecords'] as num?)?.toInt() ?? 0,
        goals: (m['goals'] as num?)?.toInt() ?? 0,
        diaryEntries: (m['diaryEntries'] as num?)?.toInt() ?? 0,
        recentSpend: (m['recentSpend'] as num?)?.toDouble() ?? 0,
        recentThemes: List<String>.from((m['recentThemes'] as List?) ?? const []),
        focus: '${m['focus'] ?? 'ambient'}',
      );
    } catch (_) {
      return null;
    }
  }
}
