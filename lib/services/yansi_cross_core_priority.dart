/// Scores fused LifeOS signals for Yansi's next-best ambient insight.
///
/// Read-only:
/// - never changes LifeOS data
/// - never executes an action
/// - never bypasses confirmation
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
      if (entry.value is! Map) continue;

      final value = entry.value as Map;

      if (value.isEmpty) continue;

      // Only trusted/read-only intelligence may enter
      // the proactive priority pipeline.
      if (value['readOnly'] == false) continue;

      final candidate = _score(
        entry.key.toString(),
        value,
      );

      final candidateConfidence = _confidence(value);

      if (candidate > score ||
          (candidate == score &&
              candidateConfidence > confidence)) {
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
          : 'Highest
