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
    final trustedCores = <String>[];

    for (final entry in signals.entries) {
      if (entry.value is! Map || (entry.value as Map).isEmpty) continue;

      final value = entry.value as Map;
      if (value['readOnly'] == false) continue;

      final candidate = _score(entry.key.toString(), value);
      final candidateConfidence = _confidence(value);
      trustedCores.add(entry.key.toString().toLowerCase());

      if (candidate > score ||
          (candidate == score && candidateConfidence > confidence)) {
        score = candidate;
        confidence = candidateConfidence;
        best = entry.key.toString();
      }
    }

    final uniqueCores = trustedCores.toSet();
    final multiCore = uniqueCores.length >= 2;

    // Independent signals reinforcing one another deserve a modest boost,
    // but never enough to exceed the 100-point safety ceiling.
    if (multiCore && best != null) {
      score = (score + 8).clamp(0, 100);
      confidence = (confidence + 5).clamp(0, 100);
    }

    return {
      'core': best,
      'score': score,
      'confidence': confidence,
      'multiCore': multiCore,
      'supportingCores': uniqueCores.toList(),
      'reason': best == null
          ? null
          : multiCore
              ? 'Multiple trusted LifeOS signals reinforce this insight'
              : 'Highest-value trusted LifeOS signal',
    };
  }

  int _score(String core, Map value) {
    final explicit = value['priority'];
    if (explicit is num) return explicit.clamp(0, 100).toInt();

    return switch (core.toLowerCase()) {
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
    if (explicit is num) return explicit.clamp(0, 100).toInt();
    return 60;
  }
}
