import 'dart:convert';

/// Derives explainable personal patterns from permanent Yansi memories.
/// This layer observes history; it never deletes or mutates it.
class YansiBehaviorPatternEngine {
  const YansiBehaviorPatternEngine();

  List<String> inferPatterns(List<Map<String, dynamic>> memories) {
    if (memories.isEmpty) return const <String>[];

    final counts = <String, int>{};
    for (final memory in memories) {
      final type = (memory['type'] ?? 'unknown').toString();
      counts[type] = (counts[type] ?? 0) + 1;
    }

    final patterns = <String>[];
    counts.forEach((type, count) {
      if (count >= 3) {
        patterns.add('Frequent $type activity detected ($count recorded events).');
      }
    });

    final allText = jsonEncode(memories).toLowerCase();
    if (allText.contains('goal')) {
      patterns.add('Goal-related activity is present in personal history.');
    }
    if (allText.contains('expense') || allText.contains('payment')) {
      patterns.add('Financial activity is present in personal history.');
    }
    if (allText.contains('task') || allText.contains('todo')) {
      patterns.add('Task/productivity activity is present in personal history.');
    }
    return List.unmodifiable(patterns);
  }
}
