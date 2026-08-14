import 'yansi_insight_memory.dart';
import 'yansi_proactive_suggestions.dart';

/// Uses previously stored useful insights as a lightweight relevance signal.
/// It never changes raw LifeOS data or executes an action.
class YansiInsightMemoryRanker {
  const YansiInsightMemoryRanker();

  List<YansiProactiveSuggestion> rank({
    required List<YansiProactiveSuggestion> current,
    required List<Map<String, dynamic>> memories,
  }) {
    if (current.isEmpty || memories.isEmpty) return current;

    final counts = <String, int>{};
    for (final memory in memories) {
      final core = '${memory['core'] ?? ''}'.trim();
      if (core.isEmpty) continue;
      counts[core] = (counts[core] ?? 0) + 1;
    }

    final ranked = current.map((item) {
      final reinforcement = (counts[item.core] ?? 0).clamp(0, 5) * 2;
      return YansiProactiveSuggestion(
        title: item.title,
        message: item.message,
        core: item.core,
        priority: (item.priority + reinforcement).clamp(0, 100).toInt(),
        speakable: item.speakable,
      );
    }).toList();

    ranked.sort((a, b) => b.priority.compareTo(a.priority));
    return ranked;
  }
}
