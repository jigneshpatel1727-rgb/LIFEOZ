import 'yansi_proactive_suggestions.dart';

/// Uses previously stored Yansi insights as a lightweight signal for ranking.
/// It does not invent new facts and never executes an action.
class YansiMemoryReinforcement {
  const YansiMemoryReinforcement();

  List<YansiProactiveSuggestion> apply({
    required List<YansiProactiveSuggestion> suggestions,
    required List<Map<String, dynamic>> memories,
  }) {
    if (suggestions.isEmpty || memories.isEmpty) return suggestions;

    final recentCoreCounts = <String, int>{};
    for (final memory in memories.take(20)) {
      final core = '${memory['core'] ?? ''}'.trim();
      if (core.isEmpty) continue;
      recentCoreCounts[core] = (recentCoreCounts[core] ?? 0) + 1;
    }

    final reinforced = suggestions.map((item) {
      final history = recentCoreCounts[item.core] ?? 0;
      if (history == 0) return item;

      final boost = (history * 2).clamp(0, 6);
      return YansiProactiveSuggestion(
        title: item.title,
        message: item.message,
        core: item.core,
        priority: (item.priority + boost).clamp(0, 100).toInt(),
        speakable: item.speakable,
      );
    }).toList();

    reinforced.sort((a, b) => b.priority.compareTo(a.priority));
    return reinforced;
  }
}
