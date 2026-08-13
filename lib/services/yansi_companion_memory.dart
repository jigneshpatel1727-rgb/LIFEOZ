import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Permission-controlled long-term companion context for Yansi.
/// Stores observations, not diagnoses, and keeps the model explainable.
class YansiCompanionMemory {
  static const _key = 'yansi_companion_memory';
  final SharedPreferences prefs;
  const YansiCompanionMemory({required this.prefs});

  bool get enabled => prefs.getBool('permission_personal_learning') == true;

  Future<void> remember(String topic, String observation, {String source = 'conversation'}) async {
    if (!enabled) return;
    final items = prefs.getStringList(_key) ?? <String>[];
    items.add(jsonEncode({
      'topic': topic.trim(),
      'observation': observation.trim(),
      'source': source,
      'createdAt': DateTime.now().toIso8601String(),
    }));
    if (items.length > 300) items.removeRange(0, items.length - 300);
    await prefs.setStringList(_key, items);
  }

  List<Map<String, dynamic>> recent({int limit = 20}) {
    final items = prefs.getStringList(_key) ?? <String>[];
    final start = items.length > limit ? items.length - limit : 0;
    return items.sublist(start).map((raw) {
      try { return Map<String, dynamic>.from(jsonDecode(raw) as Map); }
      catch (_) { return <String, dynamic>{}; }
    }).where((e) => e.isNotEmpty).toList().reversed.toList();
  }

  Future<void> clear() => prefs.remove(_key);
}
