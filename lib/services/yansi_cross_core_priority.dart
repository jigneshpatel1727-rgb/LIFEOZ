/// Scores fused LifeOS signals for Yansi's next-best ambient insight.
/// Read-only: this layer never executes an action or changes user data.
class YansiCrossCorePriority {
  const YansiCrossCorePriority();

  Map<String, dynamic> rank(Map<String, dynamic> fused) {
    final signals = fused['signals'];
    if (signals is! Map) {
      return const {'core': null, 'score': 0, 'reason': null};
    }

    String? best;
    var score = 0;
    for (final entry in signals.entries) {
      if (entry.value is! Map || (entry.value as Map).isEmpty) continue;
      final candidate = _score(entry.key.toString(), entry.value as Map);
      if (candidate > score) {
        score = candidate;
        best = entry.key.toString();
      }
    }

    return {
      'core': best,
      'score': score,
      'reason': best == null ? null : 'Highest-value active LifeOS signal',
    };
  }

  int _score(String core, Map value) {
    final explicit = value['priority'];
    if (explicit is num) return explicit.clamp(0, 100).toInt();
    return switch (core) {
      'calendar' => 80,
      'tasks' => 75,
      'expense' => 70,
      'goals' => 65,
      'household' => 60,
      _ => 50,
    };
  }
}
