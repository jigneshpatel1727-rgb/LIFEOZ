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

  /// Finds repeated user-approved topics without diagnosing personality or health.
  /// A pattern is only persisted when personal learning is enabled.
  Future<List<Map<String, dynamic>>> learnPatterns({int lookback = 60}) async {
    if (!enabled) return const [];
    final rows = recent(limit: lookback);
    final counts = <String, int>{};
    for (final row in rows) {
      final topic = (row['topic'] ?? '').toString().trim().toLowerCase();
      if (topic.isEmpty) continue;
      counts[topic] = (counts[topic] ?? 0) + 1;
    }
    final patterns = counts.entries
        .where((e) => e.value >= 2)
        .map((e) => {
              'topic': e.key,
              'frequency': e.value,
              'confidence': (0.5 + (e.value - 2) * 0.08).clamp(0.0, 0.9),
              'type': 'behavioral_pattern',
              'createdAt': DateTime.now().toIso8601String(),
            })
        .toList()
      ..sort((a, b) => (b['frequency'] as int).compareTo(a['frequency'] as int));
    await prefs.setStringList(
      'yansi_learned_patterns',
      patterns.take(30).map(jsonEncode).toList(),
    );
    return patterns;
  }

  List<Map<String, dynamic>> learnedPatterns() {
    if (!enabled) return const [];
    final rows = prefs.getStringList('yansi_learned_patterns') ?? <String>[];
    return rows.map((raw) {
      try { return Map<String, dynamic>.from(jsonDecode(raw) as Map); }
      catch (_) { return <String, dynamic>{}; }
    }).where((e) => e.isNotEmpty).toList();
  }

  Future<void> clear() async {
    await prefs.remove(_key);
    await prefs.remove('yansi_learned_patterns');
  }
}
