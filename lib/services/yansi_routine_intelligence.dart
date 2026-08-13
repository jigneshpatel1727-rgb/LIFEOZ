/// Detects recurring routine signals for proactive, low-noise assistance.
class YansiRoutineIntelligence {
  const YansiRoutineIntelligence();

  Map<String, int> activityCounts(List<Map<String, dynamic>> memories) {
    final counts = <String, int>{};
    for (final memory in memories) {
      final type = (memory['type'] ?? 'interaction').toString();
      counts[type] = (counts[type] ?? 0) + 1;
    }
    return Map.unmodifiable(counts);
  }

  List<String> recurringSignals(List<Map<String, dynamic>> memories) {
    final counts = activityCounts(memories);
    return counts.entries
        .where((entry) => entry.value >= 3)
        .map((entry) => 'Recurring ${entry.key} activity detected.')
        .toList(growable: false);
  }
}
