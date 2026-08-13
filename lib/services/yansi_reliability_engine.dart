/// Reliability layer for a dependable personal AI experience.
/// It favors truthful uncertainty, explicit state, and safe recovery over guesses.
class YansiReliabilityEngine {
  const YansiReliabilityEngine();

  Map<String, dynamic> assess({
    required bool hasContext,
    required bool actionCompleted,
    required bool externalSourceAvailable,
    required double confidence,
  }) {
    final issues = <String>[];
    if (!hasContext) issues.add('limited_context');
    if (!externalSourceAvailable) issues.add('external_source_unavailable');
    if (confidence < 0.50) issues.add('low_confidence');
    if (!actionCompleted) issues.add('action_not_confirmed');

    return {
      'reliable': issues.isEmpty,
      'issues': List.unmodifiable(issues),
      'confidence': confidence.clamp(0.0, 1.0),
    };
  }

  String responsePolicy({required bool reliable, required bool actionCompleted}) {
    if (actionCompleted) return 'Confirm the completed action clearly.';
    if (reliable) return 'Answer with the strongest supported result.';
    return 'Explain uncertainty and request the missing information rather than guessing.';
  }
}
