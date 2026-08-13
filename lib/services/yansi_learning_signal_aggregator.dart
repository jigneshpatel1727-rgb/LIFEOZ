/// Aggregates approved interaction feedback into bounded learning signals.
class YansiLearningSignalAggregator {
  const YansiLearningSignalAggregator();

  Map<String, dynamic> aggregate(
    List<Map<String, dynamic>> feedback,
  ) {
    final counts = <String, int>{};

    for (final item in feedback) {
      if (item['approved'] != true) continue;
      final signal = item['signal']?.toString().trim();
      if (signal == null || signal.isEmpty) continue;
      counts[signal] = (counts[signal] ?? 0) + 1;
    }

    return {
      'signals': Map.unmodifiable(counts),
      'approvedOnly': true,
      'learningMode': 'bounded_preference_learning',
      'autonomousCodeChange': false,
    };
  }
}
