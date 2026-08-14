/// Synthesizes evidence from predictions, scenarios, counterfactuals and
/// objectives into an adaptive judgment. It does not execute actions.
class YansiDecisionSynthesis {
  const YansiDecisionSynthesis();

  Map<String, dynamic> synthesize({
    List<Map<String, dynamic>> evidence = const [],
    List<Map<String, dynamic>> predictions = const [],
    List<Map<String, dynamic>> scenarios = const [],
    List<Map<String, dynamic>> counterfactuals = const [],
    List<Map<String, dynamic>> objectives = const [],
  }) {
    final candidates = <Map<String, dynamic>>[];
    void collect(Iterable<Map<String, dynamic>> source, String kind) {
      for (final item in source.take(12)) {
        final relevance = ((item['relevance'] as num?)?.toDouble() ??
                (item['confidence'] as num?)?.toDouble() ?? 0)
            .clamp(0, 100);
        candidates.add({
          'kind': kind,
          'relevance': relevance,
          'data': item,
        });
      }
    }

    collect(evidence, 'evidence');
    collect(predictions, 'prediction');
    collect(scenarios, 'scenario');
    collect(counterfactuals, 'counterfactual');
    candidates.sort((a, b) => (b['relevance'] as double).compareTo(a['relevance'] as double));

    final leading = candidates.isEmpty ? null : candidates.first;
    final confidence = leading == null
        ? 0.20
        : ((leading['relevance'] as double) / 100).clamp(0.0, 1.0);

    return {
      'mode': leading == null ? 'continue_learning' : 'adaptive_judgment',
      'leadingInsight': leading,
      'supportingSignals': candidates.take(8).toList(),
      'objectiveCount': objectives.length,
      'confidence': confidence,
      'certainty': confidence >= 0.8
          ? 'strong'
          : confidence >= 0.55
              ? 'developing'
              : 'tentative',
      'adaptive': true,
      'noRigidDecisionRule': true,
      'action': 'reason_only',
      'externalActionRequiresAuthority': true,
    };
  }
}
