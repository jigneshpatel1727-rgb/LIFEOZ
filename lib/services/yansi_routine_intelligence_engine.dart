/// Learns repeatable routines from verified historical events.
class YansiRoutineIntelligenceEngine {
  const YansiRoutineIntelligenceEngine();

  Map<String, dynamic> infer(List<Map<String, dynamic>> events) {
    final counts = <String, int>{};
    for (final event in events) {
      final key = (event['pattern'] ?? event['type'] ?? '').toString().trim();
      if (key.isEmpty) continue;
      counts[key] = (counts[key] ?? 0) + 1;
    }
    final repeated = counts.entries
        .where((entry) => entry.value >= 3)
        .map((entry) => {'pattern': entry.key, 'observations': entry.value})
        .toList(growable: false);
    return {
      'repeatedRoutines': List.unmodifiable(repeated),
      'learningMode': 'verified_history',
      'autoCreate': false,
    };
  }
}
