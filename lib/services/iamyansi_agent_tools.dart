import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Controlled read/write tools exposed to the iamyansi agent.
/// The agent must use these boundaries instead of directly mutating core data.
class IamyansiAgentTools {
  final SharedPreferences prefs;
  const IamyansiAgentTools({required this.prefs});

  Future<Map<String, dynamic>> readToday() async {
    final raw = prefs.getStringList('iamyansi_core_records') ?? <String>[];
    final today = DateTime.now();
    final records = raw.map((v) {
      try { return Map<String, dynamic>.from(jsonDecode(v) as Map); }
      catch (_) { return <String, dynamic>{}; }
    }).where((r) {
      final d = DateTime.tryParse('${r['createdAt'] ?? ''}');
      return d != null && d.year == today.year && d.month == today.month && d.day == today.day;
    }).toList();
    return {
      'date': '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}',
      'records': records,
      'count': records.length,
    };
  }

  Future<Map<String, dynamic>> readCore(String core) async {
    const allowed = {'expense', 'productivity', 'calendar', 'household', 'goal'};
    if (!allowed.contains(core)) return {'error': 'unsupported_core'};
    final raw = prefs.getStringList('iamyansi_core_records') ?? <String>[];
    final records = raw.map((v) {
      try { return Map<String, dynamic>.from(jsonDecode(v) as Map); }
      catch (_) { return <String, dynamic>{}; }
    }).where((r) => r['core'] == core).toList();
    return {'core': core, 'records': records, 'count': records.length};
  }

  Map<String, dynamic> availableTools() => {
        'read_today': {'access': 'read', 'confirmation': false},
        'read_core': {'access': 'read', 'confirmation': false},
        'write_core_record': {'access': 'write', 'confirmation': false},
        'sensitive_write': {'access': 'sensitive_write', 'confirmation': true},
      };
}
