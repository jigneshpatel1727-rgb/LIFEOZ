import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Local-first Phase 1 data layer for the five LifeOZ intelligence domains.
/// No network registration or external service is performed here.
class LifeOZDataStore {
  final SharedPreferences prefs;
  LifeOZDataStore(this.prefs);

  static const _expenses = 'lifeoz_expenses';
  static const _tasks = 'lifeoz_tasks';
  static const _events = 'lifeoz_events';
  static const _shopping = 'lifeoz_shopping';
  static const _diary = 'lifeoz_diary';

  List<Map<String, dynamic>> _read(String key) {
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) return <Map<String, dynamic>>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return <Map<String, dynamic>>[];
      return decoded
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    } catch (_) {
      return <Map<String, dynamic>>[];
    }
  }

  Future<void> _write(String key, List<Map<String, dynamic>> items) async {
    await prefs.setString(key, jsonEncode(items));
  }

  Future<void> addExpense({
    required double amount,
    required String category,
    String note = '',
    DateTime? date,
  }) => _add(_expenses, <String, dynamic>{
        'id': _id(),
        'amount': amount,
        'category': category,
        'note': note,
        'date': (date ?? DateTime.now()).toIso8601String(),
      });

  Future<void> addTask({
    required String title,
    bool completed = false,
    DateTime? due,
  }) => _add(_tasks, <String, dynamic>{
        'id': _id(),
        'title': title,
        'completed': completed,
        'due': (due ?? DateTime.now()).toIso8601String(),
      });

  Future<void> addEvent({
    required String title,
    required DateTime due,
    String type = 'commitment',
  }) => _add(_events, <String, dynamic>{
        'id': _id(),
        'title': title,
        'type': type,
        'due': due.toIso8601String(),
      });

  Future<void> addShoppingItem({
    required String item,
    double? estimatedAmount,
    bool completed = false,
  }) => _add(_shopping, <String, dynamic>{
        'id': _id(),
        'item': item,
        'estimatedAmount': estimatedAmount,
        'completed': completed,
      });

  Future<void> addDiaryEntry({
    required String text,
    DateTime? date,
  }) => _add(_diary, <String, dynamic>{
        'id': _id(),
        'text': text,
        'date': (date ?? DateTime.now()).toIso8601String(),
      });

  Future<void> _add(String key, Map<String, dynamic> item) async {
    final items = _read(key);
    items.insert(0, item);
    await _write(key, items);
  }

  Future<void> remove(String domain, String id) async {
    final key = switch (domain) {
      'expenses' => _expenses,
      'tasks' => _tasks,
      'events' => _events,
      'shopping' => _shopping,
      'diary' => _diary,
      _ => null,
    };
    if (key == null) return;
    final items = _read(key)..removeWhere((item) => item['id'] == id);
    await _write(key, items);
  }

  List<Map<String, dynamic>> expenses() => _read(_expenses);
  List<Map<String, dynamic>> tasks() => _read(_tasks);
  List<Map<String, dynamic>> events() => _read(_events);
  List<Map<String, dynamic>> shopping() => _read(_shopping);
  List<Map<String, dynamic>> diary() => _read(_diary);

  double totalExpenses({DateTime? from}) {
    final cutoff = from;
    return expenses().fold<double>(0, (sum, item) {
      final amount = (item['amount'] as num?)?.toDouble() ?? 0;
      if (cutoff == null) return sum + amount;
      final date = DateTime.tryParse(item['date']?.toString() ?? '');
      return date != null && date.isAfter(cutoff) ? sum + amount : sum;
    });
  }

  int pendingTasks() => tasks().where((item) => item['completed'] != true).length;

  String _id() => '${DateTime.now().microsecondsSinceEpoch}';
}
