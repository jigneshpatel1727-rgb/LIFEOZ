/// Compares alternative versions of a situation so Yansi can reason about
/// consequences before recommending a path. It does not execute any change.
class YansiCounterfactualReasoning {
  const YansiCounterfactualReasoning();

  Map<String, dynamic> compare({
    required Map<String, dynamic> baseline,
    required List<Map<String, dynamic>> alternatives,
    List<Map<String, dynamic>> objectives = const [],
  }) {
    final results = <Map<String, dynamic>>[];
    for (final alternative in alternatives.take(12)) {
      final changed = <String>[];
      alternative.forEach((key, value) {
        if (baseline[key] != value) changed.add(key);
      });

      final relevance = ((alternative['relevance'] as num?)?.toInt() ?? 50).clamp(0, 100);
      results.add({
        'alternative': alternative,
        'changedDimensions': changed,
        'relevance': relevance,
        'objectiveCount': objectives.length,
        'reasoning': 'compare_consequences',
        'status': 'possible',
        'notGuaranteed': true,
      });
    }

    results.sort((a, b) => (b['relevance'] as int).compareTo(a['relevance'] as int));
    return {
      'baseline': baseline,
      'alternatives': results,
      'mode': 'counterfactual_comparison',
      'adaptive': true,
      'noAlternativePresentedAsCertain': true,
      'externalActionRequiresAuthority': true,
    };
  }

  Map<String, dynamic> insight(Map<String, dynamic> comparison) {
    final alternatives = comparison['alternatives'];
    if (alternatives is! List || alternatives.isEmpty) {
      return {
        'mode': 'continue_reasoning',
        'message': 'There is not enough alternative context to compare meaningfully.',
      };
    }
    final best = alternatives.first;
    return {
      'mode': 'consequence_insight',
      'leadingAlternative': best,
      'message': 'This alternative currently has the strongest contextual relevance; Yansi should continue evaluating supporting evidence.',
      'requiresConfirmationForAction': true,
    };
  }
}
