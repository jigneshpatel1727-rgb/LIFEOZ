/// Ranks retained personal preferences for use by Yansi personalization.
class YansiPersonalizationPriorityEngine {
  const YansiPersonalizationPriorityEngine();

  List<Map<String, dynamic>> rank(
    Map<String, dynamic> preferenceMemory,
  ) {
    final raw = preferenceMemory['preferences'];
    if (raw is! Map) return const [];

    final entries = raw.entries.map((entry) => {
      'preference': entry.key.toString(),
      'value': entry.value,
      'priority': 1,
      'source': preferenceMemory['source'] ?? 'retained_user_preferences',
    }).toList();

    return List.unmodifiable(entries);
  }
}
