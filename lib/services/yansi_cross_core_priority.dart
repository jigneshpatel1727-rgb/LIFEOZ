/// Scores fused LifeOS signals for Yansi's next-best ambient insight.
///
/// Read-only:
/// - never changes LifeOS data
/// - never executes actions
/// - only ranks trusted intelligence signals
class YansiCrossCorePriority {
  const YansiCrossCorePriority();

  Map<String, dynamic> rank(Map<String, dynamic> fused) {
    final signals = fused['signals'];

    if (signals is! Map) {
      return const {
        'core': null,
        'score': 0,
        'confidence': 0,
        'reason': null,
      };
    }

    String? best;
    var score = 0;
    var confidence = 0;

    for (final entry in signals.entries) {
      if (entry.value is! Map || (entry.value as Map).isEmpty) {
        continue;
      }

      final value = entry.value as Map;

      // Never rank a signal that is explicitly allowed to mutate data.
      if (value['readOnly'] == false) {
        continue;
      }

      final candidate = _score(
        entry.key.toString(),
        value,
      );

      final candidateConfidence = _confidence(value);

      if (candidate > score ||
          (candidate == score && candidateConfidence > confidence)) {
        score = candidate;
        confidence = candidateConfidence;
        best = entry.key.toString();
      }
    }

    return {
      'core': best,
      'score': score,
      'confidence': confidence,
      'reason': best == null
          ? null
          : 'Highest-value trusted LifeOS signal',
    };
  }

  int _score(String core, Map value) {
    final explicit = value['priority'];

    if (explicit is num) {
      return explicit.clamp(0, 100).toInt();
    }

    return switch (core) {
      'calendar' => 80,
      'tasks' => 75,
      'expense' => 70,
      'goals' => 65,
      'household' => 60,
      _ => 50,
    };
  }

  int _confidence(Map value) {
    final explicit = value['confidence'];

    if (explicit is num) {
      return explicit.clamp(0, 100).toInt();
    }

    return 60;
  }
}
