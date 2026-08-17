import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Keeps the new iamyansi canonical record stream visible to the existing
/// five-core/report storage used by the current UI.
///
/// This is a compatibility bridge for the trial build. Canonical iamyansi
/// records remain the source of truth; existing screens can continue reading
/// their established SharedPreferences keys until their storage is migrated.
class IamyansiLegacySync {
  static const canonicalKey = 'iamyansi_core_records';
  static const _targets = <String, String>{
    'expense': 'yansi_expenses',
    'income': 'yansi_income',
    'task': 'yansi_tasks',
    'diary': 'yansi_diary',
    'reminder': 'yansi_reminders',
    'household': 'yansi_household',
    'goal': 'yansi_goals',
  };

  final SharedPreferences prefs;
  const IamyansiLegacySync({required this.prefs});

  Future<int> sync() async {
    final canonical = _read(canonicalKey);
    var added = 0;

    for (final record in canonical) {
      final type = '${record['type'] ?? ''}';
      final targetKey = _targets[type];
      if (targetKey == null) continue;

      final target = _read(targetKey);
      final id = '${record['id'] ?? ''}';
      if (id.isEmpty || target.any((item) => '${item['iamyansiId'] ?? ''}' == id)) {
        continue;
      }

      final mapped = _map(type, record);
      mapped['iamyansiId'] = id;
      mapped['source'] = 'iamyansi';
      target.add(mapped);
      await prefs.setStringList(targetKey, target.map(jsonEncode).toList());
      added++;
    }

    return added;
  }

  Map<String, dynamic> _map(String type, Map<String, dynamic> record) {
    final copy = <String, dynamic>{...record};
    copy['date'] = copy['date'] ?? copy['createdAt'] ?? DateTime.now().toIso8601String();
    if (type == 'task') {
      copy['task'] = copy['task'] ?? copy['text'] ?? '';
      copy['completed'] = copy['completed'] ?? false;
    }
    if (type == 'household') {
      copy['item'] = copy['item'] ?? copy['text'] ?? '';
    }
    if (type == 'goal') {
      copy['goal'] = copy['goal'] ?? copy['text'] ?? '';
    }
    return copy;
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
}
