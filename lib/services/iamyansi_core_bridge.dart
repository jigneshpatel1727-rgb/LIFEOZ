import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'iamyansi_intent_parser.dart';

/// Canonical persistence boundary between iamyansi and the five app cores.
///
/// Every iamyansi-created record is written once to the shared core record
/// stream. Core-specific mirrors are maintained for the existing Phase 1
/// stores where their keys are known. This keeps iamyansi from creating a
/// private database that the cores cannot see.
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
    if (intent.type == YansiIntentType.unknown ||
        intent.type == YansiIntentType.sensitiveAction) {
      return const IamyansiWriteResult.notWritten();
    }

    final now = DateTime.now();
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

    final canonical = _readList(canonicalKey);
    if (canonical.any((item) => item['id'] == id)) {
      return const IamyansiWriteResult.alreadyWritten();
    }
    canonical.add(record);
    await _writeList(canonicalKey, canonical);

    final targetKey = _targetKey(intent.type);
    final target = _readList(targetKey);
    target.add(_coreRecord(record, intent));
    await _writeList(targetKey, target);

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

  String _coreFor(YansiIntentType type) {
    switch (type) {
      case YansiIntentType.expense:
      case YansiIntentType.income:
        return 'expense';
      case YansiIntentType.task:
        return 'productivity';
      case YansiIntentType.reminder:
        return 'calendar';
      case YansiIntentType.household:
        return 'household';
      case YansiIntentType.goal:
      case YansiIntentType.diary:
        return 'goal';
      case YansiIntentType.sensitiveAction:
      case YansiIntentType.unknown:
        return 'none';
    }
  }

  String _targetKey(YansiIntentType type) {
    switch (type) {
      case YansiIntentType.expense:
      case YansiIntentType.income:
        return expenseKey;
      case YansiIntentType.task:
        return taskKey;
      case YansiIntentType.reminder:
        return calendarKey;
      case YansiIntentType.household:
        return householdKey;
      case YansiIntentType.goal:
      case YansiIntentType.diary:
        return goalKey;
      case YansiIntentType.sensitiveAction:
      case YansiIntentType.unknown:
        return canonicalKey;
    }
  }

  Map<String, dynamic> _coreRecord(
    Map<String, dynamic> record,
    YansiIntent intent,
  ) {
    final copy = Map<String, dynamic>.from(record);
    copy['value'] = intent.text;
    copy['status'] = 'open';
    return copy;
  }

  List<Map<String, dynamic>> _readList(String key) {
    final raw = prefs.getStringList(key) ?? <String>[];
    return raw.map((value) {
      try {
        return Map<String, dynamic>.from(jsonDecode(value) as Map);
      } catch (_) {
        return <String, dynamic>{};
      }
    }).where((item) => item.isNotEmpty).toList();
  }

  Future<void> _writeList(String key, List<Map<String, dynamic>> items) async {
    await prefs.setStringList(key, items.map(jsonEncode).toList());
  }
}

class IamyansiWriteResult {
  final bool written;
  final bool alreadyExists;
  final String? id;
  final String? core;

  const IamyansiWriteResult._({
    required this.written,
    required this.alreadyExists,
    this.id,
    this.core,
  });

  const IamyansiWriteResult.notWritten()
      : this._(written: false, alreadyExists: false);

  const IamyansiWriteResult.alreadyWritten()
      : this._(written: false, alreadyExists: true);

  const IamyansiWriteResult.written({required String id, required String core})
      : this._(written: true, alreadyExists: false, id: id, core: core);
}
