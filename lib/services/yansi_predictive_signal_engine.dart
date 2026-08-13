/// Detects simple emerging signals from ordered historical observations.
class YansiPredictiveSignalEngine {
  const YansiPredictiveSignalEngine();

  List<Map<String, dynamic>> detect(List<Map<String, dynamic>> observations) {
    if (observations.length < 3) return const [];

    final counts = <String, int>{};
    for (final observation in observations) {
      final key = (observation['pattern'] ?? observation['type'] ?? '').toString().trim();
      if (key.isNotEmpty) counts[key] = (counts[key] ?? 0) + 1;
    }

    return counts.entries
        .where((entry) => entry.value >= 3)
        .map((entry) => {
              'pattern': entry.key,
              'observations': entry.value,
              'signal': 'repeated_pattern',
              'prediction': 'may_recur',
              'confidence': entry.value >= 5 ? 'moderate' : 'early',
              'requiresUserReview': true,
            })
        .toList(growable: false);
  }
}
