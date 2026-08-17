import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'iamyansi_intent_parser.dart';

/// Canonical persistence boundary between iamyansi and the five app cores.
class IamyansiCoreBridge {
  static const String canonicalKey = 'iamyansi_core_records';
  static const String expenseKey = 'lifeos_expenses';
  static const String taskKey = 'iamyansi_tasks';
  static const String calendarKey = 'lifeos_calendar_events';
  static const String householdKey = 'lifeos_household_items';
  static const String goalKey = 'lifeos_goals';

  final SharedPreferences prefs;

  const IamyansiCoreBridge({required this.prefs});

  Future<IamyansiWriteResult> apply(IamyansiIntent intent) async {
    if (intent.type == IamyansiIntentType.unknown || intent.type == IamyansiIntentType.sensitiveAction) {
      return const IamyansiWriteResult.notWritten();
    }

    final now = DateTime.now();
    final canonical = _readList(canonicalKey);
    final duplicate = canonical.any((item) =>
        item['type'] == intent.type.name &&
        item['text'] == intent.text &&
        _sameDay(item['createdAt']?.toString(), now));
    if (duplicate) return const IamyansiWriteResult.alreadyWritten();

    final id = '${now.microsecondsSinceEpoch}_${intent.type.name}';
    final record = <String, dynamic>{
      'id': id,
      'source': 'iamyansi_voice',
      'core': _coreFor(intent.type),
      'type': intent.type.name,
      'text': intent.text,
      'amount': intent.amount,
      'category': intent.category,
      'createdAt': now.toIso8601String(),
      'requiresConfirmation': intent.needsConfirmation,
    };

    canonical.add(record);
    await _writeList(canonicalKey, canonical);

    // Expense already has a Phase-1 canonical bridge. Do not double-write it.
    // Other cores receive their iamyansi-created record here.
    if (intent.type != IamyansiIntentType.expense) {
      final targetKey = _targetKey(intent.type);
      final target = _readList(targetKey);
      if (!target.any((item) => item['text'] == intent.text && _sameDay(item['createdAt']?.toString(), now))) {
        target.add(_coreRecord(record, intent));
        await _writeList(targetKey, target);
      }
    }

    return IamyansiWriteResult.written(id: id, core: record['core'] as String);
  }

  Map<String, dynamic> snapshot() {
    final records = _readList(canonicalKey);
    return {
      'expense': records.where((r) => r['core'] == 'expense').length,
      'productivity': records.where((r) => r['core'] == 'productivity').length,
      'calendar': records.where((r) => r['core'] == 'calendar').length,
      'household': records.where((r) => r['core'] == 'household').length,
      'goal': records.where((r) => r['core'] == 'goal').length,
      'total': records.length,
    };
  }

  String _coreFor(IamyansiIntentType type) {
    switch (type) {
      case IamyansiIntentType.expense:
      case IamyansiIntentType.income:
        return 'expense';
      case IamyansiIntentType.task:
        return 'productivity';
      case IamyansiIntentType.reminder:
        return 'calendar';
      case IamyansiIntentType.household:
        return 'household';
      case IamyansiIntentType.goal:
      case IamyansiIntentType.diary:
        return 'goal';
      case IamyansiIntentType.sensitiveAction:
      case IamyansiIntentType.unknown:
        return 'none';
    }
  }

  String _targetKey(IamyansiIntentType type) {
    switch (type) {
      case IamyansiIntentType.expense:
      case IamyansiIntentType.income:
        return expenseKey;
      case IamyansiIntentType.task:
        return taskKey;
      case IamyansiIntentType.reminder:
        return calendarKey;
      case IamyansiIntentType.household:
        return householdKey;
      case IamyansiIntentType.goal:
      case IamyansiIntentType.diary:
        return goalKey;
      case IamyansiIntentType.sensitiveAction:
      case IamyansiIntentType.unknown:
        return canonicalKey;
    }
  }

  Map<String, dynamic> _coreRecord(Map<String, dynamic> record, IamyansiIntent intent) => {
        ...record,
        'value': intent.text,
        'status': 'open',
      };

  bool _sameDay(String? value, DateTime now) {
    final date = DateTime.tryParse(value ?? '');
    return date != null && date.year == now.year && date.month == now.month && date.day == now.day;
  }

  List<Map<String, dynamic>> _readList(String key) => (prefs.getStringList(key) ?? <String>[])
      .map((value) {
        try { return Map<String, dynamic>.from(jsonDecode(value) as Map); }
        catch (_) { return <String, dynamic>{}; }
      })
      .where((item) => item.isNotEmpty)
      .toList();

  Future<void> _writeList(String key, List<Map<String, dynamic>> items) async =>
      prefs.setStringList(key, items.map(jsonEncode).toList());
}

class IamyansiWriteResult {
  final bool written;
  final bool alreadyExists;
  final String? id;
  final String? core;

  const IamyansiWriteResult._({required this.written, required this.alreadyExists, this.id, this.core});
  const IamyansiWriteResult.notWritten() : this._(written: false, alreadyExists: false);
  const IamyansiWriteResult.alreadyWritten() : this._(written: false, alreadyExists: true);
  const IamyansiWriteResult.written({required String id, required String core}) : this._(written: true, alreadyExists: false, id: id, core: core);
}
